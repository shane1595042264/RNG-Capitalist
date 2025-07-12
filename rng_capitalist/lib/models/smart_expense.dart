// lib/models/smart_expense.dart
import 'expense_category.dart';

class SmartExpense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String? receiptImagePath;
  final ExpenseCategory category;
  final String? notes;
  final bool isRecurring;
  final Map<String, dynamic> metadata;
  final double confidence; // AI confidence in categorization

  const SmartExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.receiptImagePath,
    required this.category,
    this.notes,
    this.isRecurring = false,
    this.metadata = const {},
    this.confidence = 1.0,
  });

  factory SmartExpense.fromJson(Map<String, dynamic> json) {
    return SmartExpense(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      receiptImagePath: json['receiptImagePath'],
      category: ExpenseCategory.fromJson(json['category'] ?? {}),
      notes: json['notes'],
      isRecurring: json['isRecurring'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      confidence: (json['confidence'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'receiptImagePath': receiptImagePath,
      'category': category.toJson(),
      'notes': notes,
      'isRecurring': isRecurring,
      'metadata': metadata,
      'confidence': confidence,
    };
  }

  SmartExpense copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    String? receiptImagePath,
    ExpenseCategory? category,
    String? notes,
    bool? isRecurring,
    Map<String, dynamic>? metadata,
    double? confidence,
  }) {
    return SmartExpense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      metadata: metadata ?? this.metadata,
      confidence: confidence ?? this.confidence,
    );
  }

  bool get isDnDExpense => category.isDnDRelated;
  
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
}

class SpendingPattern {
  final String categoryId;
  final String categoryName;
  final double totalSpent;
  final double averagePerTransaction;
  final int transactionCount;
  final List<DateTime> spendingDates;
  final double budgetUtilization;
  final TrendDirection trend;

  const SpendingPattern({
    required this.categoryId,
    required this.categoryName,
    required this.totalSpent,
    required this.averagePerTransaction,
    required this.transactionCount,
    required this.spendingDates,
    required this.budgetUtilization,
    required this.trend,
  });

  factory SpendingPattern.fromExpenses(String categoryId, String categoryName, List<SmartExpense> expenses, double budgetLimit) {
    if (expenses.isEmpty) {
      return SpendingPattern(
        categoryId: categoryId,
        categoryName: categoryName,
        totalSpent: 0,
        averagePerTransaction: 0,
        transactionCount: 0,
        spendingDates: [],
        budgetUtilization: 0,
        trend: TrendDirection.stable,
      );
    }

    final totalSpent = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final averagePerTransaction = totalSpent / expenses.length;
    final spendingDates = expenses.map((e) => e.date).toList()..sort();
    final budgetUtilization = budgetLimit > 0 ? (totalSpent / budgetLimit) : 0.0;

    // Calculate trend based on recent vs older expenses
    TrendDirection trend = TrendDirection.stable;
    if (expenses.length >= 4) {
      final now = DateTime.now();
      final recentExpenses = expenses.where((e) => now.difference(e.date).inDays <= 30);
      final olderExpenses = expenses.where((e) => now.difference(e.date).inDays > 30);
      
      if (recentExpenses.isNotEmpty && olderExpenses.isNotEmpty) {
        final recentAverage = recentExpenses.fold(0.0, (sum, e) => sum + e.amount) / recentExpenses.length;
        final olderAverage = olderExpenses.fold(0.0, (sum, e) => sum + e.amount) / olderExpenses.length;
        
        if (recentAverage > olderAverage * 1.2) {
          trend = TrendDirection.increasing;
        } else if (recentAverage < olderAverage * 0.8) {
          trend = TrendDirection.decreasing;
        }
      }
    }

    return SpendingPattern(
      categoryId: categoryId,
      categoryName: categoryName,
      totalSpent: totalSpent,
      averagePerTransaction: averagePerTransaction,
      transactionCount: expenses.length,
      spendingDates: spendingDates,
      budgetUtilization: budgetUtilization,
      trend: trend,
    );
  }

  String get formattedTotalSpent => '\$${totalSpent.toStringAsFixed(2)}';
  String get formattedAveragePerTransaction => '\$${averagePerTransaction.toStringAsFixed(2)}';
  String get formattedBudgetUtilization => '${(budgetUtilization * 100).toStringAsFixed(1)}%';
}

enum TrendDirection {
  increasing,
  decreasing,
  stable,
}

class BudgetAlert {
  final String id;
  final String categoryId;
  final String categoryName;
  final AlertType type;
  final String message;
  final double currentSpent;
  final double budgetLimit;
  final AlertSeverity severity;
  final DateTime createdAt;
  final bool isAcknowledged;

  const BudgetAlert({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.message,
    required this.currentSpent,
    required this.budgetLimit,
    required this.severity,
    required this.createdAt,
    this.isAcknowledged = false,
  });

  factory BudgetAlert.fromJson(Map<String, dynamic> json) {
    return BudgetAlert(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      type: AlertType.values[json['type'] ?? 0],
      message: json['message'] ?? '',
      currentSpent: (json['currentSpent'] ?? 0.0).toDouble(),
      budgetLimit: (json['budgetLimit'] ?? 0.0).toDouble(),
      severity: AlertSeverity.values[json['severity'] ?? 0],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isAcknowledged: json['isAcknowledged'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'type': type.index,
      'message': message,
      'currentSpent': currentSpent,
      'budgetLimit': budgetLimit,
      'severity': severity.index,
      'createdAt': createdAt.toIso8601String(),
      'isAcknowledged': isAcknowledged,
    };
  }

  double get utilizationPercent => budgetLimit > 0 ? (currentSpent / budgetLimit) * 100 : 0;
  
  String get formattedUtilization => '${utilizationPercent.toStringAsFixed(1)}%';
}

enum AlertType {
  budgetWarning,
  budgetExceeded,
  unusualSpending,
  recurringReminder,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}
