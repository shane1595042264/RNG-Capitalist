// lib/components/budget_alerts_widget.dart
import 'package:flutter/material.dart';
import '../models/smart_expense.dart';
import '../services/budget_alert_service.dart';

class BudgetAlertsWidget extends StatefulWidget {
  final List<SmartExpense> expenses;

  const BudgetAlertsWidget({
    super.key,
    required this.expenses,
  });

  @override
  State<BudgetAlertsWidget> createState() => _BudgetAlertsWidgetState();
}

class _BudgetAlertsWidgetState extends State<BudgetAlertsWidget> {
  final BudgetAlertService _alertService = BudgetAlertService();
  List<BudgetAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    _alertService.alertStream.listen((alert) {
      if (mounted) {
        setState(() {
          _alerts.add(alert);
        });
      }
    });
  }

  void _loadAlerts() {
    _alertService.checkBudgetAlerts(widget.expenses);
    final activeAlerts = _alertService.getActiveAlerts();
    setState(() {
      _alerts = activeAlerts;
    });
  }

  void _acknowledgeAlert(String alertId) {
    _alertService.acknowledgeAlert(alertId);
    setState(() {
      _alerts.removeWhere((alert) => alert.id == alertId);
    });
  }

  void _clearAllAlerts() {
    _alertService.clearAcknowledgedAlerts();
    setState(() {
      _alerts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Budget Alerts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_alerts.length > 1)
                  TextButton(
                    onPressed: _clearAllAlerts,
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _alerts.take(5).length, // Show max 5 alerts
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final alert = _alerts[index];
              return _buildAlertItem(alert);
            },
          ),
          if (_alerts.length > 5)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAllAlerts(context),
                  child: Text('View ${_alerts.length - 5} more alerts'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BudgetAlert alert) {
    return ListTile(
      leading: _getAlertIcon(alert),
      title: Text(
        alert.message,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.categoryName),
          const SizedBox(height: 4),
          if (alert.budgetLimit > 0)
            LinearProgressIndicator(
              value: (alert.currentSpent / alert.budgetLimit).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getAlertColor(alert.severity),
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alert.budgetLimit > 0)
            Text(
              alert.formattedUtilization,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getAlertColor(alert.severity),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _acknowledgeAlert(alert.id),
            tooltip: 'Dismiss',
          ),
        ],
      ),
      onTap: () => _showAlertDetails(context, alert),
    );
  }

  Widget _getAlertIcon(BudgetAlert alert) {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return const Icon(Icons.error, color: Colors.red);
      case AlertSeverity.high:
        return const Icon(Icons.warning, color: Colors.orange);
      case AlertSeverity.medium:
        return const Icon(Icons.info, color: Colors.blue);
      case AlertSeverity.low:
        return const Icon(Icons.notifications, color: Colors.green);
    }
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.high:
        return Colors.orange;
      case AlertSeverity.medium:
        return Colors.blue;
      case AlertSeverity.low:
        return Colors.green;
    }
  }

  void _showAlertDetails(BuildContext context, BudgetAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _getAlertIcon(alert),
            const SizedBox(width: 8),
            Expanded(child: Text(alert.categoryName)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            const SizedBox(height: 16),
            if (alert.budgetLimit > 0) ...[
              Text(
                'Current Spending: \$${alert.currentSpent.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Budget Limit: \$${alert.budgetLimit.toStringAsFixed(2)}'),
              Text('Utilization: ${alert.formattedUtilization}'),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (alert.currentSpent / alert.budgetLimit).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getAlertColor(alert.severity),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Created: ${_formatDateTime(alert.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              _acknowledgeAlert(alert.id);
              Navigator.of(context).pop();
            },
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );
  }

  void _showAllAlerts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'All Budget Alerts',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: _alerts.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    return _buildAlertItem(alert);
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _clearAllAlerts,
                    child: const Text('Clear All'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Compact version for dashboard
class BudgetAlertsCompact extends StatefulWidget {
  final List<SmartExpense> expenses;
  final VoidCallback? onTap;

  const BudgetAlertsCompact({
    super.key,
    required this.expenses,
    this.onTap,
  });

  @override
  State<BudgetAlertsCompact> createState() => _BudgetAlertsCompactState();
}

class _BudgetAlertsCompactState extends State<BudgetAlertsCompact> {
  final BudgetAlertService _alertService = BudgetAlertService();
  List<BudgetAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    _alertService.checkBudgetAlerts(widget.expenses);
    final activeAlerts = _alertService.getActiveAlerts();
    setState(() {
      _alerts = activeAlerts;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_alerts.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text('All budgets on track'),
          subtitle: const Text('No budget alerts'),
          onTap: widget.onTap,
        ),
      );
    }

    final criticalAlerts = _alerts.where((a) => a.severity == AlertSeverity.critical).length;
    final highAlerts = _alerts.where((a) => a.severity == AlertSeverity.high).length;

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.warning,
          color: criticalAlerts > 0 ? Colors.red : Colors.orange,
        ),
        title: Text('${_alerts.length} Budget Alert${_alerts.length == 1 ? '' : 's'}'),
        subtitle: Text(
          criticalAlerts > 0
              ? '$criticalAlerts critical, $highAlerts high priority'
              : '$highAlerts high priority alerts',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (criticalAlerts > 0 ? Colors.red : Colors.orange).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_alerts.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: criticalAlerts > 0 ? Colors.red : Colors.orange,
            ),
          ),
        ),
        onTap: widget.onTap,
      ),
    );
  }
}
