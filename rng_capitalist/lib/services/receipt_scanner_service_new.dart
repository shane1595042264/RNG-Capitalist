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

      // Pre-process image for better OCR results
      final File imageFile = File(pickedFile.path);
      final processedImage = await _preprocessImage(imageFile);
      
      // Extract text using ML Kit
      final recognizedText = await _extractText(processedImage);
      
      // Parse expense data from text
      final expense = await _parseReceiptData(recognizedText, imageFile.path);
      
      // Auto-categorize based on text content
      if (expense != null) {
        final category = _categorizationService.categorizeExpense(
          expense.description,
          merchant: expense.merchant,
        );
        return expense.copyWith(category: category);
      }
      
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

      final processedImage = await _preprocessImage(imageFile);
      final recognizedText = await _extractText(processedImage);
      final expense = await _parseReceiptData(recognizedText, imagePath);
      
      if (expense != null) {
        final category = _categorizationService.categorizeExpense(
          expense.description,
          merchant: expense.merchant,
        );
        return expense.copyWith(category: category);
      }
      
      return expense;
    } catch (e) {
      print('Error scanning receipt from path: $e');
      return null;
    }
  }

  /// Pre-processes image to improve OCR accuracy
  Future<InputImage> _preprocessImage(File imageFile) async {
    try {
      // For now, use the image directly
      // Future enhancement: resize, contrast adjustment, etc.
      return InputImage.fromFile(imageFile);
    } catch (e) {
      // Fallback: resize if too large (OCR works better on medium-sized images)
      return InputImage.fromFile(imageFile);
    }
  }

  /// Extracts text from image using ML Kit
  Future<RecognizedText> _extractText(InputImage inputImage) async {
    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText;
    } catch (e) {
      print('Error extracting text: $e');
      rethrow;
    }
  }

  /// Parses expense data from recognized text
  Future<SmartExpense?> _parseReceiptData(RecognizedText recognizedText, String imagePath) async {
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

      // Extract merchant/description
      String description = _extractDescription(lines);
      String merchant = _extractMerchant(lines);

      // Extract location (optional)
      String? location = _extractLocation(lines);

      // Check if it's D&D related
      bool isDnDRelated = _isDnDRelated(lines);

      return SmartExpense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        description: description.isNotEmpty ? description : 'Receipt Purchase',
        merchant: merchant.isNotEmpty ? merchant : 'Unknown Merchant',
        date: date,
        category: isDnDRelated ? 'dnd_supplies' : 'general',
        location: location,
        imagePath: imagePath,
        ocrConfidence: _calculateConfidence(recognizedText),
        isDnDRelated: isDnDRelated,
        tags: _extractTags(lines),
        receiptData: {
          'raw_text': text,
          'extracted_lines': lines,
        },
      );
    } catch (e) {
      print('Error parsing receipt data: $e');
      return null;
    }
  }

  /// Extracts monetary amount from receipt text
  double? _extractAmount(List<String> lines) {
    // Common patterns for amounts
    final amountPatterns = [
      RegExp(r'TOTAL[\s:]*\$?(\d+\.?\d*)'), // "TOTAL $XX.XX"
      RegExp(r'AMOUNT[\s:]*\$?(\d+\.?\d*)'), // "AMOUNT $XX.XX" 
      RegExp(r'SUBTOTAL[\s:]*\$?(\d+\.?\d*)'), // "SUBTOTAL $XX.XX"
      RegExp(r'\$(\d+\.\d{2})'), // "$XX.XX" format
      RegExp(r'(\d+\.\d{2})'), // "XX.XX" format
    ];

    for (final line in lines) {
      for (final pattern in amountPatterns) {
        final match = pattern.firstMatch(line.toUpperCase());
        if (match != null) {
          final amountStr = match.group(1) ?? match.group(0)!;
          final amount = double.tryParse(amountStr.replaceAll('\$', ''));
          if (amount != null && amount > 0 && amount < 10000) { // Reasonable bounds
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
      RegExp(r'(\d{1,2})/(\d{1,2})/(\d{2,4})'), // MM/DD/YYYY or MM/DD/YY
      RegExp(r'(\d{4})/(\d{1,2})/(\d{1,2})'), // YYYY/MM/DD
      RegExp(r'(\d{1,2})-(\d{1,2})-(\d{2,4})'), // MM-DD-YYYY
    ];

    for (final line in lines) {
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            int year, month, day;
            
            if (pattern.pattern.startsWith(r'(\d{4})')) {
              // YYYY/MM/DD format
              year = int.parse(match.group(1)!);
              month = int.parse(match.group(2)!);
              day = int.parse(match.group(3)!);
            } else {
              // MM/DD/YYYY or MM-DD-YYYY format
              month = int.parse(match.group(1)!);
              day = int.parse(match.group(2)!);
              year = int.parse(match.group(3)!);
              
              // Handle 2-digit years
              if (year < 50) {
                year += 2000;
              } else if (year < 100) {
                year += 1900;
              }
            }
            
            return DateTime(year, month, day);
          } catch (e) {
            continue; // Try next pattern
          }
        }
      }
    }
    return null;
  }

  /// Extracts description from receipt text
  String _extractDescription(List<String> lines) {
    // Extract description (merchant name or item description)
    final merchantPatterns = [
      RegExp(r'([A-Z][A-Z\s&]+[A-Z])', caseSensitive: false), // ALL CAPS merchant names
      RegExp(r'^([A-Za-z\s&\'-]+)(?:\s*\n|\s*$)', multiLine: true), // First line merchant
    ];
    
    // Look for D&D specific items first
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
    
    // Try merchant patterns
    for (final line in lines) {
      for (final pattern in merchantPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null && match.group(1) != null) {
          final desc = match.group(1)!.trim();
          if (desc.length > 3 && desc.length < 50) {
            return desc;
          }
        }
      }
    }
    
    // Fallback: use first substantial line
    for (final line in lines) {
      final cleaned = line.trim();
      if (cleaned.length > 3 && cleaned.length < 50 && 
          !cleaned.contains(RegExp(r'[\d\$]'))) {
        return cleaned;
      }
    }
    
    return 'Receipt Purchase';
  }

  /// Extracts merchant name from receipt text
  String _extractMerchant(List<String> lines) {
    if (lines.isEmpty) return 'Unknown Merchant';
    
    // Try first few lines for merchant name
    for (int i = 0; i < 3 && i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.length > 2 && line.length < 30 && 
          !line.contains(RegExp(r'[\d\$]'))) {
        return line;
      }
    }
    
    return lines.first.trim();
  }

  /// Extracts location from receipt text
  String? _extractLocation(List<String> lines) {
    // Look for address patterns
    final addressPatterns = [
      RegExp(r'(\d+\s+[A-Za-z\s]+(?:St|Ave|Rd|Blvd|Dr)\.?)'), // Street address
      RegExp(r'([A-Za-z\s]+,\s*[A-Z]{2}\s+\d{5})'), // City, State ZIP
    ];

    for (final line in lines) {
      for (final pattern in addressPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return match.group(1)?.trim();
        }
      }
    }
    return null;
  }

  /// Checks if expense is D&D related based on text content
  bool _isDnDRelated(List<String> lines) {
    final dndIndicators = [
      'dice', 'd20', 'd6', 'd4', 'd8', 'd10', 'd12', 'miniature', 'mini',
      'dungeon', 'dragon', 'rpg', 'role playing', 'chessex', 'wizkids',
      'dndbeyond', 'handbook', 'manual', 'rulebook', 'players handbook',
      'dungeon master', 'dm screen', 'character sheet', 'spell', 'wizard',
      'fighter', 'rogue', 'cleric', 'barbarian', 'warlock', 'sorcerer'
    ];

    final fullText = lines.join(' ').toLowerCase();
    
    return dndIndicators.any((indicator) => fullText.contains(indicator));
  }

  /// Extracts relevant tags from receipt text
  List<String> _extractTags(List<String> lines) {
    final tags = <String>[];
    final fullText = lines.join(' ').toLowerCase();

    // D&D specific tags
    if (fullText.contains('dice')) tags.add('dice');
    if (fullText.contains('miniature') || fullText.contains('mini')) tags.add('miniatures');
    if (fullText.contains('book') || fullText.contains('manual')) tags.add('books');
    if (fullText.contains('online') || fullText.contains('digital')) tags.add('digital');
    
    return tags;
  }

  /// Calculates OCR confidence score
  double _calculateConfidence(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) return 0.0;
    
    double totalConfidence = 0.0;
    int elementCount = 0;
    
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          // Note: confidence is not always available in all ML Kit versions
          // This is a placeholder implementation
          totalConfidence += 0.8; // Assume reasonable confidence
          elementCount++;
        }
      }
    }
    
    return elementCount > 0 ? totalConfidence / elementCount : 0.0;
  }

  /// Disposes resources
  void dispose() {
    _textRecognizer.close();
  }
}
