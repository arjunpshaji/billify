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

  /// Enhanced bill details extraction with better pattern matching
  Map<String, String> extractBillDetails(String text) {
    String merchant = '';
    String amount = '';
    String date = '';
    String category = '';

    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // Extract merchant name (usually first significant line)
    if (lines.isNotEmpty) {
      // Skip very short lines or lines with just numbers
      for (var line in lines) {
        if (line.length > 3 && !RegExp(r'^\d+$').hasMatch(line)) {
          merchant = line;
          break;
        }
      }
    }

    // Extract total amount - look for keywords and patterns
    final amountPatterns = [
      RegExp(
        r'(?:total|amount|sum|balance|grand\s*total)[\s:]*\$?\s*(\d+[.,]\d{2})',
        caseSensitive: false,
      ),
      RegExp(r'\$\s*(\d+[.,]\d{2})'),
      RegExp(r'(\d+[.,]\d{2})\s*(?:total|usd|dollars?)', caseSensitive: false),
    ];

    for (var line in lines) {
      for (var pattern in amountPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          amount = match.group(1)!.replaceAll(',', '.');
          break;
        }
      }
      if (amount.isNotEmpty) break;
    }

    // If no total found, try to find the largest amount (likely the total)
    if (amount.isEmpty) {
      double maxAmount = 0;
      for (var line in lines) {
        final matches = RegExp(r'(\d+[.,]\d{2})').allMatches(line);
        for (var match in matches) {
          final value =
              double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0;
          if (value > maxAmount) {
            maxAmount = value;
            amount = match.group(1)!.replaceAll(',', '.');
          }
        }
      }
    }

    // Extract date with multiple formats
    final datePatterns = [
      RegExp(r'\b(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})\b'),
      RegExp(r'\b(\d{4}[/-]\d{1,2}[/-]\d{1,2})\b'),
      RegExp(
        r'\b((?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+\d{1,2},?\s+\d{2,4})\b',
        caseSensitive: false,
      ),
    ];

    for (var line in lines) {
      for (var pattern in datePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          date = match.group(1)!;
          break;
        }
      }
      if (date.isNotEmpty) break;
    }

    // Categorize based on merchant name or keywords
    category = _categorizeFromText(text.toLowerCase());

    return {
      'merchant': merchant,
      'amount': amount,
      'date': date,
      'category': category,
    };
  }

  /// Categorize bill based on text content
  String _categorizeFromText(String text) {
    // Groceries keywords
    if (RegExp(
      r'\b(grocery|supermarket|market|food|walmart|target|costco|kroger)\b',
    ).hasMatch(text)) {
      return 'Groceries';
    }

    // Tech keywords
    if (RegExp(
      r'\b(apple|microsoft|amazon|best buy|electronics|computer|phone|tech)\b',
    ).hasMatch(text)) {
      return 'Tech';
    }

    // Dining keywords
    if (RegExp(
      r'\b(restaurant|cafe|coffee|starbucks|mcdonald|burger|pizza|dining|food)\b',
    ).hasMatch(text)) {
      return 'Dining';
    }

    // Utilities keywords
    if (RegExp(
      r'\b(electric|gas|water|utility|power|energy|internet|cable)\b',
    ).hasMatch(text)) {
      return 'Utilities';
    }

    // Transport keywords
    if (RegExp(
      r'\b(gas station|fuel|uber|lyft|taxi|transport|parking|toll)\b',
    ).hasMatch(text)) {
      return 'Transport';
    }

    // Health keywords
    if (RegExp(
      r'\b(pharmacy|hospital|clinic|medical|health|doctor|cvs|walgreens)\b',
    ).hasMatch(text)) {
      return 'Health';
    }

    return 'Groceries'; // Default category
  }

  /// Extract all line items from receipt (filtering out totals, tax, etc.)
  List<Map<String, String>> extractLineItems(String text) {
    final items = <Map<String, String>>[];
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // Keywords that indicate this is NOT a line item
    final excludeKeywords = RegExp(
      r'\b(total|subtotal|sub-total|sub total|tax|vat|gst|hst|pst|discount|amount due|balance|grand|sum|payment|cash|card|change|tender)\b',
      caseSensitive: false,
    );

    for (var line in lines) {
      // Skip lines with exclude keywords
      if (excludeKeywords.hasMatch(line)) {
        continue;
      }

      // Match item name and price - flexible spacing
      // Handles: "Item Name 12.99", "Item Name  $12.99", "Item Name Rs 12.99"
      final itemPattern = RegExp(
        r'^(.+?)\s+(?:Rs\.?\s*|₹\s*|\$\s*|€\s*|£\s*)?(\d+[.,]\d{2})$',
        caseSensitive: false,
      );
      final match = itemPattern.firstMatch(line);

      if (match != null) {
        final itemName = match.group(1)!.trim();
        final itemPrice = match.group(2)!.replaceAll(',', '.');

        // Basic validation - name should be meaningful
        if (itemName.length > 2 && !RegExp(r'^\d+$').hasMatch(itemName)) {
          items.add({'name': itemName, 'price': itemPrice});
        }
      }
    }

    return items;
  }

  /// Detect currency from receipt text
  String detectCurrency(String text) {
    final textLower = text.toLowerCase();

    // Check for Indian Rupee first (most common patterns)
    if (text.contains('₹') ||
        textLower.contains('inr') ||
        textLower.contains('rupee') ||
        textLower.contains('rupees') ||
        RegExp(
          r'\brs\.?\s*\d',
          caseSensitive: false,
        ).hasMatch(text) || // Rs. or Rs followed by number
        RegExp(r'\d+\s*rs\.?', caseSensitive: false).hasMatch(text)) {
      // Number followed by Rs
      return 'INR';
    }

    // Check for other currencies
    if (text.contains('\$') || textLower.contains('usd')) {
      return 'USD';
    } else if (text.contains('€') || textLower.contains('eur')) {
      return 'EUR';
    } else if (text.contains('£') || textLower.contains('gbp')) {
      return 'GBP';
    } else if (text.contains('¥') ||
        textLower.contains('jpy') ||
        textLower.contains('cny')) {
      return 'JPY';
    } else if (textLower.contains('cad')) {
      return 'CAD';
    } else if (textLower.contains('aud')) {
      return 'AUD';
    }

    return 'USD'; // Default
  }

  void dispose() {
    _textRecognizer.close();
  }
}
