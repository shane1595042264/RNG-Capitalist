// lib/services/spending_analytics_service.dart
import 'dart:math';
import '../models/smart_expense.dart';

class SpendingAnalyticsService {
  static final SpendingAnalyticsService _instance = SpendingAnalyticsService._internal();
  factory SpendingAnalyticsService() => _instance;
  SpendingAnalyticsService._internal();

  /// Generates spending patterns for all categories
  List<SpendingPattern> analyzeSpendingPatterns(List<SmartExpense> expenses) {
    final categoryGroups = <String, List<SmartExpense>>{};
    final categoryNames = <String, String>{};
    final categoryLimits = <String, double>{};
    
    // Group expenses by category
    for (final expense in expenses) {
      final categoryId = expense.category.id;
      categoryGroups.putIfAbsent(categoryId, () => []).add(expense);
      categoryNames[categoryId] = expense.category.name;
      categoryLimits[categoryId] = expense.category.budgetLimit;
    }
    
    // Generate patterns for each category
    return categoryGroups.entries.map((entry) {
      return SpendingPattern.fromExpenses(
        entry.key,
        categoryNames[entry.key]!,
        entry.value,
        categoryLimits[entry.key]!,
      );
    }).toList()..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
  }

  /// Analyzes spending trends over time periods
  SpendingTrends analyzeSpendingTrends(List<SmartExpense> expenses, {int months = 6}) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months, now.day);
    
    final recentExpenses = expenses.where((e) => e.date.isAfter(startDate)).toList();
    final monthlySpending = <int, double>{};
    final categoryTrends = <String, List<double>>{};
    
    // Calculate monthly spending totals
    for (int i = 0; i < months; i++) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);
      
      final monthExpenses = recentExpenses.where((e) => 
        e.date.isAfter(monthStart) && e.date.isBefore(monthEnd)
      );
      
      final total = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
      monthlySpending[i] = total;
      
      // Track category trends
      final categoryGroups = <String, double>{};
      for (final expense in monthExpenses) {
        categoryGroups[expense.category.id] = 
          (categoryGroups[expense.category.id] ?? 0) + expense.amount;
      }
      
      for (final entry in categoryGroups.entries) {
        categoryTrends.putIfAbsent(entry.key, () => List.filled(months, 0))
          [i] = entry.value;
      }
    }
    
    return SpendingTrends(
      monthlyTotals: monthlySpending.values.toList().reversed.toList(),
      averageMonthlySpending: monthlySpending.values.isNotEmpty ? 
        monthlySpending.values.reduce((a, b) => a + b) / monthlySpending.length : 0,
      categoryTrends: categoryTrends,
      overallTrend: _calculateOverallTrend(monthlySpending.values.toList()),
    );
  }

  /// Identifies unusual spending patterns
  List<SpendingAnomaly> detectSpendingAnomalies(List<SmartExpense> expenses) {
    final anomalies = <SpendingAnomaly>[];
    final now = DateTime.now();
    
    // Analyze by category
    final categoryGroups = <String, List<SmartExpense>>{};
    for (final expense in expenses) {
      categoryGroups.putIfAbsent(expense.category.id, () => []).add(expense);
    }
    
    for (final entry in categoryGroups.entries) {
      final categoryExpenses = entry.value;
      if (categoryExpenses.length < 3) continue; // Need history for anomaly detection
      
      // Calculate statistics
      final amounts = categoryExpenses.map((e) => e.amount).toList();
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = amounts.map((a) => pow(a - mean, 2)).reduce((a, b) => a + b) / amounts.length;
      final stdDev = sqrt(variance);
      
      // Check for recent anomalies (last 30 days)
      final recentExpenses = categoryExpenses.where((e) => 
        now.difference(e.date).inDays <= 30
      );
      
      for (final expense in recentExpenses) {
        final zScore = (expense.amount - mean) / stdDev;
        
        if (zScore.abs() > 2.0) { // More than 2 standard deviations
          anomalies.add(SpendingAnomaly(
            expense: expense,
            type: zScore > 0 ? AnomalyType.unusuallyHigh : AnomalyType.unusuallyLow,
            severity: zScore.abs() > 3.0 ? 'High' : 'Medium',
            description: zScore > 0 
              ? 'This ${expense.category.name} expense is unusually high compared to your typical spending'
              : 'This ${expense.category.name} expense is unusually low compared to your typical spending',
            expectedRange: '${(mean - stdDev).toStringAsFixed(2)} - ${(mean + stdDev).toStringAsFixed(2)}',
          ));
        }
      }
      
      // Check for frequency anomalies
      final monthlyFrequency = _calculateMonthlyFrequency(categoryExpenses);
      final currentMonthExpenses = categoryExpenses.where((e) => 
        e.date.year == now.year && e.date.month == now.month
      ).length;
      
      if (currentMonthExpenses > monthlyFrequency * 2) {
        anomalies.add(SpendingAnomaly(
          expense: categoryExpenses.last,
          type: AnomalyType.unusualFrequency,
          severity: 'Medium',
          description: 'You\'ve made $currentMonthExpenses ${entry.value.first.category.name} purchases this month, which is unusually frequent',
          expectedRange: '${monthlyFrequency.toStringAsFixed(1)} purchases per month',
        ));
      }
    }
    
    return anomalies..sort((a, b) => b.expense.date.compareTo(a.expense.date));
  }

  /// Generates personalized spending insights
  List<SpendingInsight> generateSpendingInsights(List<SmartExpense> expenses) {
    final insights = <SpendingInsight>[];
    final patterns = analyzeSpendingPatterns(expenses);
    
    // Top spending category insight
    if (patterns.isNotEmpty) {
      final topCategory = patterns.first;
      insights.add(SpendingInsight(
        title: 'Top Spending Category',
        description: '${topCategory.categoryName} accounts for your highest expenses',
        value: topCategory.formattedTotalSpent,
        type: InsightType.topCategory,
        actionable: topCategory.budgetUtilization > 0.8,
        recommendation: topCategory.budgetUtilization > 0.8 
          ? 'Consider setting a stricter budget for ${topCategory.categoryName}'
          : null,
      ));
    }
    
    // D&D spending insight
    final dndExpenses = expenses.where((e) => e.isDnDExpense).toList();
    if (dndExpenses.isNotEmpty) {
      final totalDnDSpending = dndExpenses.fold(0.0, (sum, e) => sum + e.amount);
      final dndPercentage = (totalDnDSpending / expenses.fold(0.0, (sum, e) => sum + e.amount)) * 100;
      
      insights.add(SpendingInsight(
        title: 'D&D Gaming Expenses',
        description: '${dndPercentage.toStringAsFixed(1)}% of your spending is D&D related',
        value: '\$${totalDnDSpending.toStringAsFixed(2)}',
        type: InsightType.dndSpending,
        actionable: dndPercentage > 50,
        recommendation: dndPercentage > 50 
          ? 'Your D&D hobby is a major expense category. Consider tracking individual campaign costs.'
          : null,
      ));
    }
    
    // Budget utilization insights
    for (final pattern in patterns) {
      if (pattern.budgetUtilization > 0.9) {
        insights.add(SpendingInsight(
          title: 'Budget Alert',
          description: 'You\'ve used ${pattern.formattedBudgetUtilization} of your ${pattern.categoryName} budget',
          value: pattern.formattedTotalSpent,
          type: InsightType.budgetWarning,
          actionable: true,
          recommendation: 'Consider reducing ${pattern.categoryName} spending for the rest of the month',
        ));
      }
    }
    
    // Savings opportunities
    final expensiveCategories = patterns.where((p) => p.averagePerTransaction > 25).toList();
    for (final category in expensiveCategories.take(2)) {
      insights.add(SpendingInsight(
        title: 'Savings Opportunity',
        description: 'Your average ${category.categoryName} purchase is ${category.formattedAveragePerTransaction}',
        value: category.formattedAveragePerTransaction,
        type: InsightType.savingsOpportunity,
        actionable: true,
        recommendation: 'Look for deals or bulk purchases to reduce per-item costs',
      ));
    }
    
    return insights;
  }

  /// Calculates monthly frequency for a category
  double _calculateMonthlyFrequency(List<SmartExpense> expenses) {
    if (expenses.isEmpty) return 0;
    
    final sortedExpenses = expenses..sort((a, b) => a.date.compareTo(b.date));
    final firstExpense = sortedExpenses.first;
    final lastExpense = sortedExpenses.last;
    
    final monthsDiff = ((lastExpense.date.year - firstExpense.date.year) * 12 + 
                       lastExpense.date.month - firstExpense.date.month) + 1;
    
    return expenses.length / monthsDiff;
  }

  /// Calculates overall spending trend
  TrendDirection _calculateOverallTrend(List<double> monthlyTotals) {
    if (monthlyTotals.length < 2) return TrendDirection.stable;
    
    final recentAverage = monthlyTotals.take(3).reduce((a, b) => a + b) / 3;
    final olderAverage = monthlyTotals.skip(3).take(3).isNotEmpty 
      ? monthlyTotals.skip(3).take(3).reduce((a, b) => a + b) / 3
      : recentAverage;
    
    if (recentAverage > olderAverage * 1.15) return TrendDirection.increasing;
    if (recentAverage < olderAverage * 0.85) return TrendDirection.decreasing;
    return TrendDirection.stable;
  }
}

class SpendingTrends {
  final List<double> monthlyTotals;
  final double averageMonthlySpending;
  final Map<String, List<double>> categoryTrends;
  final TrendDirection overallTrend;

  const SpendingTrends({
    required this.monthlyTotals,
    required this.averageMonthlySpending,
    required this.categoryTrends,
    required this.overallTrend,
  });
}

class SpendingAnomaly {
  final SmartExpense expense;
  final AnomalyType type;
  final String severity;
  final String description;
  final String expectedRange;

  const SpendingAnomaly({
    required this.expense,
    required this.type,
    required this.severity,
    required this.description,
    required this.expectedRange,
  });
}

enum AnomalyType {
  unusuallyHigh,
  unusuallyLow,
  unusualFrequency,
}

class SpendingInsight {
  final String title;
  final String description;
  final String value;
  final InsightType type;
  final bool actionable;
  final String? recommendation;

  const SpendingInsight({
    required this.title,
    required this.description,
    required this.value,
    required this.type,
    this.actionable = false,
    this.recommendation,
  });
}

enum InsightType {
  topCategory,
  dndSpending,
  budgetWarning,
  savingsOpportunity,
  trend,
}
