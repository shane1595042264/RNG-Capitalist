// lib/components/spending_analytics_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/smart_expense.dart';
import '../services/spending_analytics_service.dart';

class SpendingAnalyticsDashboard extends StatefulWidget {
  final List<SmartExpense> expenses;

  const SpendingAnalyticsDashboard({
    super.key,
    required this.expenses,
  });

  @override
  State<SpendingAnalyticsDashboard> createState() => _SpendingAnalyticsDashboardState();
}

class _SpendingAnalyticsDashboardState extends State<SpendingAnalyticsDashboard>
    with TickerProviderStateMixin {
  final SpendingAnalyticsService _analyticsService = SpendingAnalyticsService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patterns = _analyticsService.analyzeSpendingPatterns(widget.expenses);
    final trends = _analyticsService.analyzeSpendingTrends(widget.expenses);
    final insights = _analyticsService.generateSpendingInsights(widget.expenses);
    final anomalies = _analyticsService.detectSpendingAnomalies(widget.expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analytics'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Insights'),
            Tab(icon: Icon(Icons.warning), text: 'Anomalies'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(patterns),
          _buildTrendsTab(trends),
          _buildInsightsTab(insights),
          _buildAnomaliesTab(anomalies),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(List<SpendingPattern> patterns) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalSpendingCard(),
          const SizedBox(height: 16),
          _buildSpendingPieChart(patterns),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(patterns),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(SpendingTrends trends) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthlyTrendCard(trends),
          const SizedBox(height: 16),
          _buildMonthlySpendingChart(trends),
          const SizedBox(height: 16),
          _buildTrendSummary(trends),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(List<SpendingInsight> insights) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: insights.length,
      itemBuilder: (context, index) => _buildInsightCard(insights[index]),
    );
  }

  Widget _buildAnomaliesTab(List<SpendingAnomaly> anomalies) {
    if (anomalies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No unusual spending detected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your spending patterns look normal',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: anomalies.length,
      itemBuilder: (context, index) => _buildAnomalyCard(anomalies[index]),
    );
  }

  Widget _buildTotalSpendingCard() {
    final totalSpent = widget.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final dndSpent = widget.expenses.where((e) => e.isDnDExpense).fold(0.0, (sum, e) => sum + e.amount);
    final dndPercentage = totalSpent > 0 ? (dndSpent / totalSpent) * 100 : 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Spending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${totalSpent.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('D&D Expenses', style: TextStyle(color: Colors.grey)),
                    Text(
                      '\$${dndSpent.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('D&D %', style: TextStyle(color: Colors.grey)),
                    Text(
                      '${dndPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingPieChart(List<SpendingPattern> patterns) {
    if (patterns.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No spending data available')),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: patterns.take(6).map((pattern) {
                    final color = _getCategoryColor(pattern.categoryId);
                    return PieChartSectionData(
                      color: color,
                      value: pattern.totalSpent,
                      title: '${((pattern.totalSpent / patterns.fold(0.0, (sum, p) => sum + p.totalSpent)) * 100).toStringAsFixed(1)}%',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      radius: 100,
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<SpendingPattern> patterns) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...patterns.map((pattern) => _buildCategoryItem(pattern)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(SpendingPattern pattern) {
    final color = _getCategoryColor(pattern.categoryId);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pattern.categoryName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${pattern.transactionCount} transactions • ${pattern.formattedAveragePerTransaction} avg',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pattern.formattedTotalSpent,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (pattern.budgetUtilization > 0)
                Text(
                  pattern.formattedBudgetUtilization,
                  style: TextStyle(
                    color: pattern.budgetUtilization > 0.8 ? Colors.red : Colors.green,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendCard(SpendingTrends trends) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  trends.overallTrend == TrendDirection.increasing
                      ? Icons.trending_up
                      : trends.overallTrend == TrendDirection.decreasing
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  color: trends.overallTrend == TrendDirection.increasing
                      ? Colors.red
                      : trends.overallTrend == TrendDirection.decreasing
                          ? Colors.green
                          : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTrendDescription(trends.overallTrend),
                  style: TextStyle(
                    color: trends.overallTrend == TrendDirection.increasing
                        ? Colors.red
                        : trends.overallTrend == TrendDirection.decreasing
                            ? Colors.green
                            : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Average: \$${trends.averageMonthlySpending.toStringAsFixed(2)}/month',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySpendingChart(SpendingTrends trends) {
    if (trends.monthlyTotals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No trend data available')),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Spending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          final now = DateTime.now();
                          final monthIndex = (now.month - trends.monthlyTotals.length + value.toInt()) % 12;
                          return Text(months[monthIndex], style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: trends.monthlyTotals.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.purple,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendSummary(SpendingTrends trends) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('• Average monthly spending: \$${trends.averageMonthlySpending.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            if (trends.monthlyTotals.isNotEmpty) ...[
              Text('• Highest month: \$${trends.monthlyTotals.reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('• Lowest month: \$${trends.monthlyTotals.reduce((a, b) => a < b ? a : b).toStringAsFixed(2)}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(SpendingInsight insight) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getInsightIcon(insight.type), color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (insight.actionable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Action Needed',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(insight.description),
            const SizedBox(height: 8),
            Text(
              insight.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            if (insight.recommendation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.recommendation!,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalyCard(SpendingAnomaly anomaly) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: anomaly.severity == 'High' ? Colors.red : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${anomaly.expense.category.name} - ${anomaly.expense.formattedDate}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (anomaly.severity == 'High' ? Colors.red : Colors.orange).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    anomaly.severity,
                    style: TextStyle(
                      fontSize: 12,
                      color: anomaly.severity == 'High' ? Colors.red : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(anomaly.description),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount: ${anomaly.expense.formattedAmount}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Expected: ${anomaly.expectedRange}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'dice': return Colors.pink;
      case 'books': return Colors.indigo;
      case 'miniatures': return Colors.orange;
      case 'accessories': return Colors.green;
      case 'digital': return Colors.purple;
      case 'food_gaming': return Colors.deepOrange;
      default: return Colors.blueGrey;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.topCategory: return Icons.pie_chart;
      case InsightType.dndSpending: return Icons.casino;
      case InsightType.budgetWarning: return Icons.warning;
      case InsightType.savingsOpportunity: return Icons.savings;
      case InsightType.trend: return Icons.trending_up;
    }
  }

  String _getTrendDescription(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.increasing: return 'Spending is increasing';
      case TrendDirection.decreasing: return 'Spending is decreasing';
      case TrendDirection.stable: return 'Spending is stable';
    }
  }
}
