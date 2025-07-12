// lib/services/receipt_scanner_service.dart
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../models/smart_expense.dart';
import 'smart_categorization_service.dart';

class ReceiptScannerService {
  static final ReceiptScannerService _instance = ReceiptScannerService._internal();
  factory ReceiptScannerService() => _instance;
  ReceiptScannerService._internal();

  final _textRecognizer = TextRecognizer();
  final _picker = ImagePicker();
  final _categorizationService = SmartCategorizationService();

  /// Scans receipt from camera or gallery
  Future<SmartExpense?> scanReceipt({bool fromCamera = true}) async {
    try {
      // Pick image
      final ImageSource source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      final XFile? pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile == null) return null;

      // Extract text using ML Kit
      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Parse expense data from text
      final expense = await _parseReceiptData(recognizedText);
      
      return expense;
    } catch (e) {
      print('Error scanning receipt: $e');
      return null;
    }
  }

  /// Analyzes image from file path
  Future<SmartExpense?> scanReceiptFromPath(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) return null;

      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final expense = await _parseReceiptData(recognizedText);
      
      return expense;
    } catch (e) {
      print('Error scanning receipt from path: $e');
      return null;
    }
  }

  /// Parses expense data from recognized text
  Future<SmartExpense?> _parseReceiptData(RecognizedText recognizedText) async {
    try {
      final text = recognizedText.text;
      if (text.trim().isEmpty) return null;

      final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      // Extract amount
      double? amount = _extractAmount(lines);
      if (amount == null || amount <= 0) return null;

      // Extract date
      DateTime? date = _extractDate(lines);
      date ??= DateTime.now(); // Fallback to current date

      // Extract description
      String description = _extractDescription(lines);

      // Auto-categorize based on text content
      final category = await _categorizationService.categorizeFromText('', description);

      return SmartExpense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        description: description.isNotEmpty ? description : 'Receipt Purchase',
        date: date,
        category: category,
        notes: 'Scanned from receipt',
      );
    } catch (e) {
      print('Error parsing receipt data: $e');
      return null;
    }
  }

  /// Extracts monetary amount from receipt text
  double? _extractAmount(List<String> lines) {
    final amountPatterns = [
      RegExp(r'TOTAL[\s:]*\$?(\d+\.?\d*)'),
      RegExp(r'AMOUNT[\s:]*\$?(\d+\.?\d*)'),
      RegExp(r'SUBTOTAL[\s:]*\$?(\d+\.?\d*)'),
      RegExp(r'\$(\d+\.\d{2})'),
      RegExp(r'(\d+\.\d{2})'),
    ];

    for (final line in lines) {
      for (final pattern in amountPatterns) {
        final match = pattern.firstMatch(line.toUpperCase());
        if (match != null) {
          final amountStr = match.group(1) ?? match.group(0)!;
          final amount = double.tryParse(amountStr.replaceAll('\$', ''));
          if (amount != null && amount > 0 && amount < 10000) {
            return amount;
          }
        }
      }
    }
    return null;
  }

  /// Extracts date from receipt text
  DateTime? _extractDate(List<String> lines) {
    final datePatterns = [
      RegExp(r'(\d{1,2})/(\d{1,2})/(\d{2,4})'),
      RegExp(r'(\d{4})/(\d{1,2})/(\d{1,2})'),
      RegExp(r'(\d{1,2})-(\d{1,2})-(\d{2,4})'),
    ];

    for (final line in lines) {
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            int year, month, day;
            
            if (pattern.pattern.startsWith(r'(\d{4})')) {
              year = int.parse(match.group(1)!);
              month = int.parse(match.group(2)!);
              day = int.parse(match.group(3)!);
            } else {
              month = int.parse(match.group(1)!);
              day = int.parse(match.group(2)!);
              year = int.parse(match.group(3)!);
              
              if (year < 50) {
                year += 2000;
              } else if (year < 100) {
                year += 1900;
              }
            }
            
            return DateTime(year, month, day);
          } catch (e) {
            continue;
          }
        }
      }
    }
    return null;
  }

  /// Extracts description from receipt text
  String _extractDescription(List<String> lines) {
    final dndKeywords = ['dice', 'd20', 'd6', 'd4', 'd8', 'd10', 'd12', 'miniature', 'mini', 
                         'dungeon', 'dragon', 'rpg', 'roleplay', 'chessex', 'wizkids', 
                         'dndbeyond', 'handbook', 'manual', 'rulebook'];
    
    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      for (final keyword in dndKeywords) {
        if (lowerLine.contains(keyword)) {
          return line.trim();
        }
      }
    }
    
    for (final line in lines) {
      final cleaned = line.trim();
      if (cleaned.length > 3 && cleaned.length < 50 && 
          !cleaned.contains(RegExp(r'^\d+[\.\d]*$'))) {
        return cleaned;
      }
    }
    
    return 'Receipt Purchase';
  }

  /// Disposes resources
  void dispose() {
    _textRecognizer.close();
  }
}
