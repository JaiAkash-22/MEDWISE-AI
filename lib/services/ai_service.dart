import 'dart:convert';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

/// Result of asking the AI to identify a medicine and explain it.
class AiExplanationResult {
  final String medicineName;
  final String explanation;
  AiExplanationResult({required this.medicineName, required this.explanation});
}

/// Turns raw OCR text into an identified medicine name + a plain-language
/// explanation, using Groq's free-tier API. Responds in whichever
/// language is selected in Settings.
class AiService {
  // TODO: paste your Groq API key here.
  static const String apiKey = os.getenv('API_KEY');

  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'openai/gpt-oss-20b';

  Future<AiExplanationResult> explain(String ocrText) async {
    final language = SettingsService().language.label;

    final systemPrompt = '''
You are MedWise AI, a warm, patient assistant who explains medicine labels
the way a caring nurse would explain them to a worried family member.

You will be given raw, sometimes messy text read by OCR off a medicine
label or box. First, figure out the actual medicine name from that text
(ignore batch codes, barcodes, manufacturer taglines, or stray printed
words — find the real drug/product name). Then explain it.

Respond with ONLY a JSON object, no other text, in this exact shape:
{"medicine_name": "...", "explanation": "..."}

The "explanation" value must be written in $language and should, briefly
and in plain conversational language:
1. Say what this medicine is commonly used for, in everyday terms.
2. Explain in one simple sentence how it generally helps the body.
3. Mention one or two common things to watch out for, described calmly.
4. End with a short, natural line encouraging the person to confirm with
   a doctor or pharmacist — like a caring suggestion, not a legal notice.

Rules:
- Never invent a specific dosage or schedule not printed on the label.
- Never diagnose, prescribe, or tell someone to start/stop a medicine.
- Keep the explanation under 130 words total.
- Short sentences, no clinical jargon left unexplained.
- If you truly cannot identify a medicine name from the text, set
  "medicine_name" to "Unknown Medicine".
''';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'response_format': {'type': 'json_object'},
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'OCR text from the label:\n$ocrText'},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content == null) return _fallback();

        final parsed = jsonDecode(content);
        final name = parsed['medicine_name']?.toString().trim();
        final explanation = parsed['explanation']?.toString().trim();

        if (name == null || name.isEmpty || explanation == null || explanation.isEmpty) {
          return _fallback();
        }
        return AiExplanationResult(medicineName: name, explanation: explanation);
      } else {
        // ignore: avoid_print
        print('Groq API error ${response.statusCode}: ${response.body}');
        return _fallback();
      }
    } catch (e) {
      // ignore: avoid_print
      print('AI service exception: $e');
      return _fallback();
    }
  }

  AiExplanationResult _fallback() {
    return AiExplanationResult(
      medicineName: 'Unknown Medicine',
      explanation: "We couldn't reach the explanation service right now. "
          "Please check your internet connection and try again, or "
          "confirm this medicine's use directly with a pharmacist.",
    );
  }
}