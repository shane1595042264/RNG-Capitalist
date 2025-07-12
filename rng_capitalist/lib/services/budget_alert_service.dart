// lib/services/budget_alert_service.dart
import 'dart:async';
import '../models/smart_expense.dart';

class BudgetAlertService {
  static final BudgetAlertService _instance = BudgetAlertService._internal();
  factory BudgetAlertService() => _instance;
  BudgetAlertService._internal();

  final List<BudgetAlert> _alerts = [];
  final StreamController<BudgetAlert> _alertController = StreamController<BudgetAlert>.broadcast();

  Stream<BudgetAlert> get alertStream => _alertController.stream;

  /// Checks expenses against budgets and generates alerts
  List<BudgetAlert> checkBudgetAlerts(List<SmartExpense> expenses) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final currentMonthExpenses = expenses.where((e) => e.date.isAfter(monthStart)).toList();
    
    final categorySpending = <String, double>{};
    final categoryLimits = <String, double>{};
    final categoryNames = <String, String>{};
    
    // Calculate current month spending by category
    for (final expense in currentMonthExpenses) {
      final categoryId = expense.category.id;
      categorySpending[categoryId] = (categorySpending[categoryId] ?? 0) + expense.amount;
      categoryLimits[categoryId] = expense.category.budgetLimit;
      categoryNames[categoryId] = expense.category.name;
    }
    
    final newAlerts = <BudgetAlert>[];
    
    for (final entry in categorySpending.entries) {
      final categoryId = entry.key;
      final spent = entry.value;
      final limit = categoryLimits[categoryId] ?? 0;
      final categoryName = categoryNames[categoryId] ?? 'Unknown';
      
      if (limit <= 0) continue; // Skip categories without budget limits
      
      final utilizationPercent = (spent / limit) * 100;
      
      // Generate alerts based on utilization thresholds
      if (utilizationPercent >= 100) {
        // Budget exceeded
        newAlerts.add(_createAlert(
          categoryId: categoryId,
          categoryName: categoryName,
          type: AlertType.budgetExceeded,
          severity: AlertSeverity.critical,
          currentSpent: spent,
          budgetLimit: limit,
          message: 'You\'ve exceeded your $categoryName budget by \$${(spent - limit).toStringAsFixed(2)}!',
        ));
      } else if (utilizationPercent >= 90) {
        // 90% warning
        newAlerts.add(_createAlert(
          categoryId: categoryId,
          categoryName: categoryName,
          type: AlertType.budgetWarning,
          severity: AlertSeverity.high,
          currentSpent: spent,
          budgetLimit: limit,
          message: 'You\'ve used ${utilizationPercent.toStringAsFixed(1)}% of your $categoryName budget',
        ));
      } else if (utilizationPercent >= 75) {
        // 75% warning
        newAlerts.add(_createAlert(
          categoryId: categoryId,
          categoryName: categoryName,
          type: AlertType.budgetWarning,
          severity: AlertSeverity.medium,
          currentSpent: spent,
          budgetLimit: limit,
          message: 'You\'re at ${utilizationPercent.toStringAsFixed(1)}% of your $categoryName budget',
        ));
      }
    }
    
    // Check for unusual spending patterns
    newAlerts.addAll(_checkUnusualSpending(currentMonthExpenses));
    
    // Add new alerts to the list and notify listeners
    for (final alert in newAlerts) {
      if (!_isDuplicateAlert(alert)) {
        _alerts.add(alert);
        _alertController.add(alert);
      }
    }
    
    return newAlerts;
  }

  /// Checks for unusual spending patterns that might warrant alerts
  List<BudgetAlert> _checkUnusualSpending(List<SmartExpense> expenses) {
    final alerts = <BudgetAlert>[];
    final now = DateTime.now();
    
    // Group by category and check for unusual activity
    final categoryGroups = <String, List<SmartExpense>>{};
    for (final expense in expenses) {
      categoryGroups.putIfAbsent(expense.category.id, () => []).add(expense);
    }
    
    for (final entry in categoryGroups.entries) {
      final categoryExpenses = entry.value;
      if (categoryExpenses.length < 2) continue;
      
      final categoryName = categoryExpenses.first.category.name;
      final totalSpent = categoryExpenses.fold(0.0, (sum, e) => sum + e.amount);
      
      // Check for rapid successive purchases (3+ in one day)
      final today = DateTime(now.year, now.month, now.day);
      final todaysExpenses = categoryExpenses.where((e) => 
        e.date.year == today.year && 
        e.date.month == today.month && 
        e.date.day == today.day
      ).toList();
      
      if (todaysExpenses.length >= 3) {
        alerts.add(_createAlert(
          categoryId: entry.key,
          categoryName: categoryName,
          type: AlertType.unusualSpending,
          severity: AlertSeverity.medium,
          currentSpent: totalSpent,
          budgetLimit: categoryExpenses.first.category.budgetLimit,
          message: 'You\'ve made ${todaysExpenses.length} $categoryName purchases today',
        ));
      }
      
      // Check for large single purchases (>50% of monthly budget)
      final budgetLimit = categoryExpenses.first.category.budgetLimit;
      for (final expense in categoryExpenses) {
        if (budgetLimit > 0 && expense.amount > budgetLimit * 0.5) {
          alerts.add(_createAlert(
            categoryId: entry.key,
            categoryName: categoryName,
            type: AlertType.unusualSpending,
            severity: AlertSeverity.high,
            currentSpent: expense.amount,
            budgetLimit: budgetLimit,
            message: 'Large $categoryName purchase: ${expense.formattedAmount} (${((expense.amount / budgetLimit) * 100).toStringAsFixed(1)}% of monthly budget)',
          ));
        }
      }
    }
    
    return alerts;
  }

  /// Creates a new budget alert
  BudgetAlert _createAlert({
    required String categoryId,
    required String categoryName,
    required AlertType type,
    required AlertSeverity severity,
    required double currentSpent,
    required double budgetLimit,
    required String message,
  }) {
    return BudgetAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: categoryId,
      categoryName: categoryName,
      type: type,
      message: message,
      currentSpent: currentSpent,
      budgetLimit: budgetLimit,
      severity: severity,
      createdAt: DateTime.now(),
    );
  }

  /// Checks if an alert is a duplicate of an existing one
  bool _isDuplicateAlert(BudgetAlert newAlert) {
    final now = DateTime.now();
    
    return _alerts.any((existing) =>
      existing.categoryId == newAlert.categoryId &&
      existing.type == newAlert.type &&
      existing.severity == newAlert.severity &&
      now.difference(existing.createdAt).inHours < 24 // Don't duplicate within 24 hours
    );
  }

  /// Gets all active alerts
  List<BudgetAlert> getActiveAlerts() {
    final now = DateTime.now();
    // Remove old alerts (older than 7 days) and return active ones
    _alerts.removeWhere((alert) => now.difference(alert.createdAt).inDays > 7);
    return List.from(_alerts.where((alert) => !alert.isAcknowledged));
  }

  /// Acknowledges an alert (marks it as read)
  void acknowledgeAlert(String alertId) {
    final alertIndex = _alerts.indexWhere((alert) => alert.id == alertId);
    if (alertIndex != -1) {
      _alerts[alertIndex] = BudgetAlert(
        id: _alerts[alertIndex].id,
        categoryId: _alerts[alertIndex].categoryId,
        categoryName: _alerts[alertIndex].categoryName,
        type: _alerts[alertIndex].type,
        message: _alerts[alertIndex].message,
        currentSpent: _alerts[alertIndex].currentSpent,
        budgetLimit: _alerts[alertIndex].budgetLimit,
        severity: _alerts[alertIndex].severity,
        createdAt: _alerts[alertIndex].createdAt,
        isAcknowledged: true,
      );
    }
  }

  /// Clears all acknowledged alerts
  void clearAcknowledgedAlerts() {
    _alerts.removeWhere((alert) => alert.isAcknowledged);
  }

  /// Sets up recurring budget reminders
  void setupRecurringReminders() {
    // Set up monthly budget reset reminders
    Timer.periodic(const Duration(days: 1), (timer) {
      final now = DateTime.now();
      if (now.day == 1) { // First day of month
        _createMonthlyBudgetReminder();
      }
      
      // Weekly spending summary (every Sunday)
      if (now.weekday == 7) {
        _createWeeklySpendingSummary();
      }
    });
  }

  /// Creates monthly budget reset reminder
  void _createMonthlyBudgetReminder() {
    final alert = _createAlert(
      categoryId: 'monthly_reminder',
      categoryName: 'Monthly Budget',
      type: AlertType.recurringReminder,
      severity: AlertSeverity.low,
      currentSpent: 0,
      budgetLimit: 0,
      message: 'New month, fresh budgets! Time to plan your D&D expenses.',
    );
    
    _alerts.add(alert);
    _alertController.add(alert);
  }

  /// Creates weekly spending summary
  void _createWeeklySpendingSummary() {
    final alert = _createAlert(
      categoryId: 'weekly_summary',
      categoryName: 'Weekly Summary',
      type: AlertType.recurringReminder,
      severity: AlertSeverity.low,
      currentSpent: 0,
      budgetLimit: 0,
      message: 'Weekly spending summary is ready! Check your D&D budget performance.',
    );
    
    _alerts.add(alert);
    _alertController.add(alert);
  }

  /// Dispose of resources
  void dispose() {
    _alertController.close();
  }
}
