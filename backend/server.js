require('dotenv').config();

const express = require('express');

const app = express();

const PORT = process.env.PORT || 3000;

const GROQ_API_KEY = process.env.GROQ_API_KEY;

const GROQ_API_URL =
    'https://api.groq.com/openai/v1/chat/completions';

const MODEL = 'openai/gpt-oss-20b';

app.use(express.json({ limit: '100kb' }));


// --------------------------------------------------
// HEALTH CHECK
// --------------------------------------------------

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'MedWise AI Backend',
  });
});


// --------------------------------------------------
// MEDICINE EXPLANATION
// --------------------------------------------------

app.post('/api/explain', async (req, res) => {
  try {
    // Check API key
    if (!GROQ_API_KEY) {
      console.error('GROQ_API_KEY is missing.');

      return res.status(500).json({
        error: 'AI service is not configured.',
      });
    }


    // Get data from Flutter
    const { ocrText, language } = req.body;


    // Validate OCR text
    if (!ocrText || typeof ocrText !== 'string') {
      return res.status(400).json({
        error: 'OCR text is required.',
      });
    }


    // Selected language
    const selectedLanguage =
        typeof language === 'string' && language.trim()
            ? language.trim()
            : 'English';


    // --------------------------------------------------
    // MEDWISE AI SYSTEM PROMPT
    // --------------------------------------------------

    const systemPrompt = `
You are MedWise AI, a warm and helpful medicine information assistant.

You will receive raw text extracted from a medicine label or medicine
package using OCR. The OCR text may contain spelling mistakes, batch
numbers, manufacturer information, prices, barcodes, or unrelated text.

Your job is to identify the medicine name as accurately as possible and
provide a simple explanation.

Respond ONLY with a valid JSON object in this exact format:

{
  "medicine_name": "...",
  "explanation": "..."
}

The explanation must be written in ${selectedLanguage}.

The explanation should briefly include:

1. What the medicine is commonly used for.
2. How it generally helps the body.
3. One or two common side effects or things to watch for.
4. A short suggestion to confirm medicine-related decisions with a doctor
   or pharmacist.

Important safety rules:

- Do NOT prescribe medicines.
- Do NOT diagnose medical conditions.
- Do NOT tell the user to start, stop, or change a medicine.
- Do NOT invent a dosage or schedule.
- Do NOT invent information that is not reasonably supported.
- If the medicine cannot be identified reliably, use
  "Unknown Medicine" as the medicine_name.
- Keep the explanation simple and easy to understand.
- Keep the explanation under 130 words.
- Do not include markdown.
- Return JSON only.
`;


    // --------------------------------------------------
    // CALL GROQ
    // --------------------------------------------------

    const groqResponse = await fetch(
        GROQ_API_URL,
        {
          method: 'POST',

          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${GROQ_API_KEY}`,
          },

          body: JSON.stringify({
            model: MODEL,

            response_format: {
              type: 'json_object',
            },

            messages: [
              {
                role: 'system',
                content: systemPrompt,
              },

              {
                role: 'user',
                content:
                    `OCR text from the medicine label:\n\n${ocrText}`,
              },
            ],
          }),
        },
    );


    // --------------------------------------------------
    // HANDLE GROQ RESPONSE
    // --------------------------------------------------

    const responseText = await groqResponse.text();


    if (!groqResponse.ok) {
      console.error(
        `Groq API error ${groqResponse.status}:`,
        responseText,
      );

      return res.status(502).json({
        error: 'AI provider request failed.',
      });
    }


    // Parse Groq response
    let groqData;

    try {
      groqData = JSON.parse(responseText);
    } catch (error) {
      console.error(
        'Invalid Groq response:',
        responseText,
      );

      return res.status(502).json({
        error: 'Invalid AI provider response.',
      });
    }


    // Get AI content
    const content =
        groqData?.choices?.[0]?.message?.content;


    if (!content) {
      return res.status(502).json({
        error: 'AI provider returned an empty response.',
      });
    }


    // --------------------------------------------------
    // PARSE AI JSON
    // --------------------------------------------------

    let parsed;

    try {
      parsed = JSON.parse(content);
    } catch (error) {
      console.error(
        'AI returned invalid JSON:',
        content,
      );

      return res.status(502).json({
        error: 'AI returned an invalid explanation.',
      });
    }


    // --------------------------------------------------
    // VALIDATE RESULT
    // --------------------------------------------------

    const medicineName =
        typeof parsed.medicine_name === 'string'
            ? parsed.medicine_name.trim()
            : '';

    const explanation =
        typeof parsed.explanation === 'string'
            ? parsed.explanation.trim()
            : '';


    if (!medicineName || !explanation) {
      return res.status(502).json({
        error: 'AI explanation was incomplete.',
      });
    }


    // --------------------------------------------------
    // SEND RESULT TO FLUTTER
    // --------------------------------------------------

    return res.json({
      medicine_name: medicineName,
      explanation: explanation,
    });

  } catch (error) {

    console.error(
      'MedWise backend error:',
      error,
    );

    return res.status(500).json({
      error: 'Something went wrong while processing the request.',
    });
  }
});


// --------------------------------------------------
// START SERVER
// --------------------------------------------------

app.listen(PORT, '0.0.0.0', () => {
  console.log(
    `MedWise AI backend running on 0.0.0.0:${PORT}`,
  );
});