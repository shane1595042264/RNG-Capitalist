// lib/models/expense_category.dart
class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final bool isDnDRelated;
  final List<String> keywords;
  final double budgetLimit;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isDnDRelated,
    required this.keywords,
    this.budgetLimit = 0.0,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '🎲',
      color: json['color'] ?? '#9C27B0',
      isDnDRelated: json['isDnDRelated'] ?? false,
      keywords: List<String>.from(json['keywords'] ?? []),
      budgetLimit: (json['budgetLimit'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isDnDRelated': isDnDRelated,
      'keywords': keywords,
      'budgetLimit': budgetLimit,
    };
  }

  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    bool? isDnDRelated,
    List<String>? keywords,
    double? budgetLimit,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDnDRelated: isDnDRelated ?? this.isDnDRelated,
      keywords: keywords ?? this.keywords,
      budgetLimit: budgetLimit ?? this.budgetLimit,
    );
  }
}

// Predefined D&D categories
class DnDCategories {
  static const List<ExpenseCategory> defaultCategories = [
    ExpenseCategory(
      id: 'dice',
      name: 'Dice & Accessories',
      icon: '🎲',
      color: '#E91E63',
      isDnDRelated: true,
      keywords: ['dice', 'd20', 'd6', 'd4', 'd8', 'd10', 'd12', 'polyhedral', 'chessex'],
      budgetLimit: 50.0,
    ),
    ExpenseCategory(
      id: 'books',
      name: 'Books & Rulebooks',
      icon: '📚',
      color: '#3F51B5',
      isDnDRelated: true,
      keywords: ['player handbook', 'dungeon master', 'monster manual', 'sourcebook', 'guide', 'dnd', 'd&d'],
      budgetLimit: 100.0,
    ),
    ExpenseCategory(
      id: 'miniatures',
      name: 'Miniatures & Models',
      icon: '🏰',
      color: '#FF9800',
      isDnDRelated: true,
      keywords: ['miniature', 'mini', 'figure', 'model', 'painting', 'warhammer', 'reaper'],
      budgetLimit: 75.0,
    ),
    ExpenseCategory(
      id: 'accessories',
      name: 'Gaming Accessories',
      icon: '⚔️',
      color: '#4CAF50',
      isDnDRelated: true,
      keywords: ['screen', 'mat', 'marker', 'token', 'bag', 'case', 'organizer'],
      budgetLimit: 40.0,
    ),
    ExpenseCategory(
      id: 'digital',
      name: 'Digital Content',
      icon: '💻',
      color: '#9C27B0',
      isDnDRelated: true,
      keywords: ['dndbeyond', 'roll20', 'fantasy grounds', 'subscription', 'digital', 'online'],
      budgetLimit: 30.0,
    ),
    ExpenseCategory(
      id: 'food_gaming',
      name: 'Gaming Snacks & Drinks',
      icon: '🍕',
      color: '#FF5722',
      isDnDRelated: true,
      keywords: ['pizza', 'snacks', 'drinks', 'session', 'game night'],
      budgetLimit: 25.0,
    ),
    ExpenseCategory(
      id: 'general',
      name: 'General Expenses',
      icon: '💳',
      color: '#607D8B',
      isDnDRelated: false,
      keywords: [],
      budgetLimit: 0.0,
    ),
  ];

  // Static getters for easy access
  static ExpenseCategory get diceAndAccessories => defaultCategories[0];
  static ExpenseCategory get booksAndRulebooks => defaultCategories[1];
  static ExpenseCategory get miniaturesAndModels => defaultCategories[2];
  static ExpenseCategory get gamingAccessories => defaultCategories[3];
  static ExpenseCategory get digitalContent => defaultCategories[4];
  static ExpenseCategory get gamingSnacks => defaultCategories[5];
  static ExpenseCategory get generalExpenses => defaultCategories[6];

  // Method to get all categories
  static List<ExpenseCategory> getAllCategories() {
    return List.from(defaultCategories);
  }

  // Method to get D&D related categories only
  static List<ExpenseCategory> getDnDCategories() {
    return defaultCategories.where((cat) => cat.isDnDRelated).toList();
  }

  // Method to find category by ID
  static ExpenseCategory? findById(String id) {
    try {
      return defaultCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}
