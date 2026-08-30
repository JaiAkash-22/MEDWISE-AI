import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Reads printed text off a photographed medicine label.
/// This is step 2 of the core journey: Scan -> Recognize -> Explain -> Support.
class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// Takes a photo file and returns the raw recognized text.
  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await _recognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Very small heuristic to guess the medicine name from OCR text —
  /// takes the first non-empty line, since medicine names are usually
  /// printed largest/first on a strip. Good enough for a hackathon demo;
  /// refine with real label samples during Day 5 testing.
  String guessMedicineName(String rawText) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    return lines.isNotEmpty ? lines.first : 'Unknown';
  }

  void dispose() {
    _recognizer.close();
  }
}
