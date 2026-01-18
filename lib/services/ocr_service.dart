import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );
    return recognizedText.text;
  }

  Map<String, String> extractBillDetails(String text) {
    String title = '';
    String amount = '';
    String date = '';

    final lines = text.split('\n');

    // Simple implementation - can be improved with Regex
    for (String line in lines) {
      // Amount heuristic: look for $ or typical decimal patterns
      if (amount.isEmpty &&
          (line.contains('\$') || RegExp(r'\d+\.\d{2}').hasMatch(line))) {
        // cleanup to get just numbers
        final match = RegExp(r'(\d+\.\d{2})').firstMatch(line);
        if (match != null) {
          amount = match.group(1)!;
        }
      }

      // Date heuristic
      if (date.isEmpty && (line.contains('/') || line.contains('-'))) {
        if (RegExp(r'\d{2}[/-]\d{2}[/-]\d{2,4}').hasMatch(line)) {
          date = line;
        }
      }

      // Title/Merchant heuristic: usually the first non-empty line
      if (title.isEmpty && line.trim().isNotEmpty && line.length > 3) {
        title = line.trim();
      }
    }

    return {
      'title': title,
      'amount': amount,
      'date': date, // Keeping as string for now, UI can parse
    };
  }

  void dispose() {
    _textRecognizer.close();
  }
}
