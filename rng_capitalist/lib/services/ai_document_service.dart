// lib/services/ai_document_service.dart - AI-Powered Document Analysis Service
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/sunk_cost.dart';

class AIDocumentService {
  static final AIDocumentService _instance = AIDocumentService._internal();
  factory AIDocumentService() => _instance;
  AIDocumentService._internal();

  final _textRecognizer = TextRecognizer();
  GenerativeModel? _geminiModel;

  // Initialize Gemini AI model with API key from environment
  void _initializeGemini() {
    if (_geminiModel == null) {
      final apiKey = dotenv.env['GOOGLE_GEMINI_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
        debugPrint('❌ ERROR: Google Gemini API key not found!');
        debugPrint('Please set GOOGLE_GEMINI_API_KEY in your .env file');
        debugPrint('Get a free API key from: https://aistudio.google.com/app/apikey');
        throw Exception('Google Gemini API key not configured. Please check your .env file.');
      }
      
      _geminiModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      
      debugPrint('✅ Google Gemini AI initialized successfully');
    }
  }

  /// Main analysis method that processes documents using real AI
  Future<List<SunkCost>> analyzeDocument(String filePath) async {
    try {
      _initializeGemini();
      
      final file = File(filePath);
      final extension = filePath.toLowerCase().split('.').last;

      String extractedText = '';
      
      if (extension == 'pdf') {
        extractedText = await _extractTextFromPDF(file);
      } else {
        extractedText = await _extractTextFromImage(file);
      }

      debugPrint('📄 Extracted text from $extension file: ${extractedText.length} characters');
      
      if (extractedText.trim().isEmpty) {
        debugPrint('⚠️ No text extracted from document');
        return [];
      }

      // Use AI to analyze the document content
      return await _analyzeWithAI(extractedText, filePath);
    } catch (e) {
      debugPrint('❌ Error analyzing document: $e');
      return [];
    }
  }

  /// Extracts text from PDF files
  Future<String> _extractTextFromPDF(File pdfFile) async {
    try {
      final document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
      final extractedText = StringBuffer();
      final extractor = PdfTextExtractor(document);
      
      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        extractedText.writeln(pageText);
      }
      
      document.dispose();
      return extractedText.toString();
    } catch (e) {
      debugPrint('Error extracting text from PDF: $e');
      return '';
    }
  }

  /// Extracts text from image files using OCR
  Future<String> _extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error extracting text from image: $e');
      return '';
    }
  }

  /// AI-powered analysis using Google Gemini
  Future<List<SunkCost>> _analyzeWithAI(String documentText, String sourceFile) async {
    try {
      debugPrint('🤖 Starting AI analysis with Gemini...');
      
      final prompt = '''
You are an expert financial document analyzer specializing in identifying sunk costs from receipts, bank statements, invoices, and financial documents.

Analyze the following document text and extract ALL sunk costs (money already spent that cannot be recovered). Focus especially on:
- Tuition payments and educational expenses
- Gaming equipment and D&D supplies
- Entertainment purchases
- Subscription services
- Shopping and retail purchases
- Any other non-investment expenses

Document text:
```
$documentText
```

For each sunk cost found, provide a JSON response with this exact format:
{
  "sunk_costs": [
    {
      "name": "Clear, descriptive name of the expense",
      "amount": 1234.56,
      "category": "One of: Education, Gaming Equipment, Entertainment, Subscriptions, Shopping, Food & Dining, Transportation, Healthcare, Utilities, General",
      "confidence": 0.95,
      "reasoning": "Brief explanation of why this is a sunk cost"
    }
  ]
}

Important rules:
1. Only include expenses that are clearly sunk costs (money already spent)
2. Be accurate with amounts - parse numbers like "1,124.22" correctly as 1124.22
3. Provide meaningful, specific names (not just "Transaction" or "Payment")
4. Choose the most appropriate category from the list
5. Include confidence score (0.0 to 1.0)
6. If you see tuition, university, or college payments, categorize as "Education"
7. Look for context clues to understand what purchases are for
8. Don't include transfers between accounts or deposits
9. Return empty array if no sunk costs found

Respond ONLY with valid JSON, no other text.
''';

      final content = [Content.text(prompt)];
      final response = await _geminiModel!.generateContent(content);
      final responseText = response.text ?? '';
      
      debugPrint('🤖 AI Response: ${responseText.substring(0, responseText.length > 200 ? 200 : responseText.length)}...');
      
      return _parseAIResponse(responseText);
    } catch (e) {
      debugPrint('❌ Error in AI analysis: $e');
      // Fallback to basic parsing if AI fails
      return _fallbackParsing(documentText);
    }
  }

  /// Parse the AI response JSON into SunkCost objects
  List<SunkCost> _parseAIResponse(String responseText) {
    try {
      // Clean up the response text to extract JSON
      String jsonText = responseText.trim();
      
      // Remove markdown code blocks if present
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      
      final jsonData = json.decode(jsonText);
      final sunkCostsData = jsonData['sunk_costs'] as List?;
      
      if (sunkCostsData == null) {
        debugPrint('⚠️ No sunk_costs array found in AI response');
        return [];
      }
      
      final sunkCosts = <SunkCost>[];
      
      for (final costData in sunkCostsData) {
        try {
          final name = costData['name'] as String? ?? 'Unknown Expense';
          final amount = (costData['amount'] as num?)?.toDouble() ?? 0.0;
          final category = costData['category'] as String? ?? 'General';
          final confidence = (costData['confidence'] as num?)?.toDouble() ?? 0.5;
          final reasoning = costData['reasoning'] as String? ?? '';
          
          if (amount > 0 && amount <= 100000) { // Reasonable bounds
            debugPrint('✅ AI found sunk cost: "$name" - \$${amount.toStringAsFixed(2)} - Category: $category (${(confidence * 100).toStringAsFixed(0)}% confidence)');
            debugPrint('   Reasoning: $reasoning');
            
            sunkCosts.add(SunkCost(
              name: name,
              amount: amount,
              category: category,
            ));
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing individual sunk cost: $e');
        }
      }
      
      debugPrint('🎯 AI successfully parsed ${sunkCosts.length} sunk costs');
      return sunkCosts;
    } catch (e) {
      debugPrint('❌ Error parsing AI response: $e');
      return [];
    }
  }

  /// Fallback parsing if AI fails
  List<SunkCost> _fallbackParsing(String text) {
    debugPrint('🔄 Using fallback parsing method...');
    
    final sunkCosts = <SunkCost>[];
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    // Simple regex patterns as fallback
    final amountPattern = RegExp(r'\$(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false);
    
    for (final line in lines) {
      final matches = amountPattern.allMatches(line);
      for (final match in matches) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        final amount = double.tryParse(amountStr);
        
        if (amount != null && amount > 0 && amount <= 50000) {
          String description = line.replaceAll(match.group(0)!, '').trim();
          if (description.isEmpty || description.length < 5) {
            description = 'Transaction';
          }
          
          String category = 'General';
          final lowerText = line.toLowerCase();
          if (lowerText.contains('tuition') || lowerText.contains('university') || lowerText.contains('unc')) {
            category = 'Education';
          } else if (lowerText.contains('game') || lowerText.contains('dice')) {
            category = 'Gaming Equipment';
          }
          
          sunkCosts.add(SunkCost(
            name: description,
            amount: amount,
            category: category,
          ));
        }
      }
    }
    
    debugPrint('📝 Fallback parsing found ${sunkCosts.length} sunk costs');
    return sunkCosts;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
