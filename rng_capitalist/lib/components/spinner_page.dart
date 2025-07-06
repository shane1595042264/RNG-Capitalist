// lib/components/spinner_page.dart
import 'package:flutter/material.dart';
import '../models/sunk_cost.dart';
import '../components/sunk_cost_spinner.dart';

class SpinnerPage extends StatefulWidget {
  final List<SunkCost> sunkCosts;

  const SpinnerPage({
    Key? key,
    required this.sunkCosts,
  }) : super(key: key);

  @override
  State<SpinnerPage> createState() => _SpinnerPageState();
}

class _SpinnerPageState extends State<SpinnerPage> {
  SunkCost? _lastResult;
  List<SunkCost> _spinHistory = [];

  List<SunkCost> get _activeSunkCosts {
    return widget.sunkCosts.where((cost) => cost.isActive).toList();
  }

  double get _totalSunkCostValue {
    return _activeSunkCosts.fold(0.0, (sum, cost) => sum + cost.amount);
  }

  void _onSpinResult(SunkCost result) {
    setState(() {
      _lastResult = result;
      _spinHistory.insert(0, result);
      // Keep only last 10 results
      if (_spinHistory.length > 10) {
        _spinHistory.removeLast();
      }
    });
  }

  String _generateActivitySuggestion(SunkCost sunkCost) {
    final category = sunkCost.category.toLowerCase();
    
    if (category.contains('education') || category.contains('learning')) {
      return 'Study or work on ${sunkCost.name} for 1-2 hours';
    } else if (category.contains('game') || category.contains('gaming')) {
      return 'Play ${sunkCost.name} for 30-60 minutes';
    } else if (category.contains('fitness') || category.contains('health')) {
      return 'Use ${sunkCost.name} for a workout session';
    } else if (category.contains('hobby') || category.contains('creative')) {
      return 'Work on your ${sunkCost.name} project';
    } else {
      return 'Spend some time with ${sunkCost.name}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[600]!, Colors.purple[800]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.casino,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sunk Cost Spinner',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'What should you focus on next?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Stats - Make them wrap on smaller screens
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildStatCard(
                      'Active Investments',
                      '${_activeSunkCosts.length}',
                      Icons.trending_up,
                      Colors.white,
                    ),
                    _buildStatCard(
                      'Total Value',
                      '\$${_totalSunkCostValue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.white,
                    ),
                    _buildStatCard(
                      'Spins Today',
                      '${_spinHistory.length}',
                      Icons.refresh,
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main Content - Make it scrollable
          Expanded(
            child: _activeSunkCosts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.casino,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active sunk costs',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Go to Sunk Costs page to add your investments',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isWideScreen
                          ? _buildWideLayout()
                          : _buildNarrowLayout(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spinner Section
        Expanded(
          flex: 2,
          child: _buildSpinnerSection(),
        ),
        const SizedBox(width: 16),
        // Sidebar
        SizedBox(
          width: 350,
          child: _buildSidebar(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        // Spinner Section
        _buildSpinnerSection(),
        const SizedBox(height: 16),
        // Sidebar content below spinner
        _buildSidebar(),
      ],
    );
  }

  Widget _buildSpinnerSection() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 500,
        maxHeight: 700,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.casino,
                  color: Colors.purple[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Spin to Decide',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  'Click the center to spin!',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SunkCostSpinner(
              sunkCosts: widget.sunkCosts,
              onSpinResult: _onSpinResult,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        // Current Result
        if (_lastResult != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Current Focus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _lastResult!.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${_lastResult!.category}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Investment: \$${_lastResult!.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Suggestion:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _generateActivitySuggestion(_lastResult!),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Spin History
        if (_spinHistory.isNotEmpty)
          Container(
            constraints: const BoxConstraints(
              maxHeight: 400,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recent Spins',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _spinHistory.length,
                    itemBuilder: (context, index) {
                      final item = _spinHistory[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '\$${item.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: textColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
