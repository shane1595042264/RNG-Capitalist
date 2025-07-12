// lib/services/smart_categorization_service.dart
import '../models/expense_category.dart';

class SmartCategorizationService {
  static final SmartCategorizationService _instance = SmartCategorizationService._internal();
  factory SmartCategorizationService() => _instance;
  SmartCategorizationService._internal();

  final List<ExpenseCategory> _categories = DnDCategories.getAllCategories();

  /// Categorizes an expense based on description and optional OCR text
  Future<ExpenseCategory> categorizeFromText(String ocrText, String description) async {
    final combinedText = '$ocrText $description'.toLowerCase();
    
    ExpenseCategory? bestMatch;
    int highestScore = 0;
    
    for (final category in _categories) {
      final score = _calculateCategoryScore(combinedText, category);
      if (score > highestScore) {
        highestScore = score;
        bestMatch = category;
      }
    }
    
    // Return best match if confidence is high enough, otherwise return general category
    if (highestScore >= 2 && bestMatch != null) {
      return bestMatch;
    }
    
    return DnDCategories.generalExpenses;
  }

  /// Categorizes based on merchant name and amount patterns
  ExpenseCategory categorizeFromMerchant(String merchantName, double amount) {
    final lowerMerchant = merchantName.toLowerCase();
    
    // Check for specific D&D merchants and stores
    final merchantMappings = {
      // Online D&D stores
      'dndbeyond': DnDCategories.digitalContent,
      'drivethrurpg': DnDCategories.digitalContent,
      'roll20': DnDCategories.digitalContent,
      
      // Dice and gaming stores
      'chessex': DnDCategories.diceAndAccessories,
      'dice': DnDCategories.diceAndAccessories,
      'gaming': DnDCategories.gamingAccessories,
      
      // Book stores (likely for D&D books)
      'amazon': _categorizeBooksFromAmount(amount),
      'barnes': DnDCategories.booksAndRulebooks,
      'book': DnDCategories.booksAndRulebooks,
      
      // Miniature stores
      'wizkids': DnDCategories.miniaturesAndModels,
      'reaper': DnDCategories.miniaturesAndModels,
      'miniature': DnDCategories.miniaturesAndModels,
      
      // General gaming stores
      'game': DnDCategories.gamingAccessories,
      'hobby': DnDCategories.gamingAccessories,
      
      // Food and snacks
      'pizza': DnDCategories.gamingSnacks,
      'subway': DnDCategories.gamingSnacks,
      'doordash': DnDCategories.gamingSnacks,
      'ubereats': DnDCategories.gamingSnacks,
      'grubhub': DnDCategories.gamingSnacks,
      'mcdonald': DnDCategories.gamingSnacks,
      'taco': DnDCategories.gamingSnacks,
      'starbucks': DnDCategories.gamingSnacks,
      'dunkin': DnDCategories.gamingSnacks,
    };
    
    for (final entry in merchantMappings.entries) {
      if (lowerMerchant.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Amount-based categorization for unknown merchants
    return _categorizeByAmount(amount);
  }

  /// Suggests category based on spending patterns and history
  Future<List<ExpenseCategory>> suggestCategories(
    String description, 
    double amount,
    List<String> recentMerchants,
  ) async {
    final suggestions = <ExpenseCategory>[];
    
    // Primary suggestion from text analysis
    final primaryCategory = await categorizeFromText('', description);
    suggestions.add(primaryCategory);
    
    // Amount-based suggestions
    final amountCategory = _categorizeByAmount(amount);
    if (amountCategory.id != primaryCategory.id) {
      suggestions.add(amountCategory);
    }
    
    // Pattern-based suggestions from recent merchants
    for (final merchant in recentMerchants.take(5)) {
      final merchantCategory = categorizeFromMerchant(merchant, amount);
      if (!suggestions.any((cat) => cat.id == merchantCategory.id)) {
        suggestions.add(merchantCategory);
      }
      if (suggestions.length >= 3) break;
    }
    
    return suggestions;
  }

  /// Calculates how well a category matches the given text
  int _calculateCategoryScore(String text, ExpenseCategory category) {
    int score = 0;
    
    // Check exact keyword matches
    for (final keyword in category.keywords) {
      if (text.contains(keyword.toLowerCase())) {
        score += 3; // High weight for exact keyword matches
      }
    }
    
    // Check partial matches and related terms
    final dndTerms = {
      'dice': ['die', 'roll', 'rolling', 'd4', 'd6', 'd8', 'd10', 'd12', 'd20', 'd100'],
      'book': ['manual', 'guide', 'handbook', 'rulebook', 'supplement'],
      'miniature': ['mini', 'figure', 'model', 'pewter', 'plastic'],
      'digital': ['pdf', 'online', 'subscription', 'app', 'virtual'],
      'snack': ['food', 'drink', 'beverage', 'pizza', 'soda'],
      'accessory': ['bag', 'case', 'mat', 'screen', 'token'],
    };
    
    for (final categoryKeyword in category.keywords) {
      final relatedTerms = dndTerms[categoryKeyword.toLowerCase()] ?? [];
      for (final term in relatedTerms) {
        if (text.contains(term)) {
          score += 1; // Lower weight for related terms
        }
      }
    }
    
    // Bonus for D&D specific categories if D&D terms are found
    if (category.isDnDRelated && _containsDnDTerms(text)) {
      score += 2;
    }
    
    return score;
  }

  /// Categorizes based on amount patterns
  ExpenseCategory _categorizeByAmount(double amount) {
    if (amount <= 15) {
      return DnDCategories.diceAndAccessories; // Typical dice set price
    } else if (amount <= 30) {
      return DnDCategories.gamingSnacks; // Typical snack/food order
    } else if (amount <= 40) {
      return DnDCategories.digitalContent; // Digital purchases
    } else if (amount <= 60) {
      return DnDCategories.booksAndRulebooks; // D&D books
    } else if (amount <= 100) {
      return DnDCategories.miniaturesAndModels; // Miniature sets
    } else {
      return DnDCategories.generalExpenses; // Large purchases
    }
  }

  /// Special categorization for book purchases from Amazon (could be D&D or general)
  ExpenseCategory _categorizeBooksFromAmount(double amount) {
    // D&D books typically cost $30-60, general books less
    if (amount >= 25 && amount <= 70) {
      return DnDCategories.booksAndRulebooks;
    }
    return DnDCategories.generalExpenses;
  }

  /// Checks if text contains general D&D terms
  bool _containsDnDTerms(String text) {
    final dndTerms = [
      'dnd', 'd&d', 'dungeons', 'dragons', 'rpg', 'roleplay', 'tabletop',
      'campaign', 'adventure', 'character', 'dm', 'dungeon master',
      'player', 'party', 'guild', 'fantasy', 'magic', 'spell'
    ];
    
    for (final term in dndTerms) {
      if (text.contains(term)) {
        return true;
      }
    }
    return false;
  }

  /// Learns from user corrections to improve future categorization
  void learnFromCorrection(String originalText, ExpenseCategory wrongCategory, ExpenseCategory correctCategory) {
    // In a real app, this would update ML models or keyword weights
    // For now, we'll just log the correction for future improvements
    print('Learning: "$originalText" was categorized as ${wrongCategory.name} but should be ${correctCategory.name}');
  }

  /// Gets confidence score for a categorization
  double getCategorizeConfidence(String text, ExpenseCategory category) {
    final score = _calculateCategoryScore(text.toLowerCase(), category);
    
    // Convert score to confidence percentage
    if (score >= 5) return 0.95;
    if (score >= 3) return 0.8;
    if (score >= 2) return 0.65;
    if (score >= 1) return 0.5;
    return 0.3; // Low confidence for no matches
  }
}
