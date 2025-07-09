// lib/components/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sunk_cost.dart';
import '../utils/schedule_generator.dart';

class SchedulePage extends StatefulWidget {
  final List<SunkCost> sunkCosts;

  const SchedulePage({
    Key? key,
    required this.sunkCosts,
  }) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DailySchedule? _currentSchedule;
  int _periodDurationHours = 2;
  bool _isGenerating = false;

  List<SunkCost> get _activeSunkCosts {
    return widget.sunkCosts.where((cost) => cost.isActive).toList();
  }

  double get _totalSunkCostValue {
    return _activeSunkCosts.fold(0.0, (sum, cost) => sum + cost.amount);
  }

  void _generateSchedule() async {
    if (_activeSunkCosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add and activate some sunk costs first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Add a small delay for UI feedback
    await Future.delayed(const Duration(milliseconds: 500));

    final schedule = ScheduleGenerator.generateDailySchedule(
      sunkCosts: widget.sunkCosts,
      date: DateTime.now(),
      periodDurationHours: _periodDurationHours,
    );

    setState(() {
      _currentSchedule = schedule;
      _isGenerating = false;
    });
  }

  void _copyGoogleCalendarLink() {
    if (_currentSchedule == null) return;

    final url = ScheduleGenerator.generateGoogleCalendarUrl(_currentSchedule!);
    Clipboard.setData(ClipboardData(text: url));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Calendar link copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Generate consistent colors for categories
    final hash = category.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
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
                    Icon(
                      Icons.schedule,
                      color: Colors.blue[700],
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Daily Schedule Generator',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (_currentSchedule != null)
                      ElevatedButton.icon(
                        onPressed: _copyGoogleCalendarLink,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Copy to Google Calendar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Generate a 24-hour schedule based on your sunk cost investments.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Controls
                Row(
                  children: [
                    // Period Duration Setting
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Period Duration:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue[300]!),
                            ),
                            child: DropdownButton<int>(
                              value: _periodDurationHours,
                              underline: const SizedBox(),
                              items: [1, 2, 3, 4, 6, 8, 12].map((hours) {
                                return DropdownMenuItem(
                                  value: hours,
                                  child: Text('$hours hour${hours > 1 ? 's' : ''}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _periodDurationHours = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    // Active Sunk Costs Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Active Investments:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_activeSunkCosts.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Total: \$${_totalSunkCostValue.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    
                    // Generate Button
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateSchedule,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Schedule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Schedule Display
          Expanded(
            child: _currentSchedule == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No schedule generated yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click "Generate Schedule" to create your daily plan',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Schedule Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[600]!, Colors.blue[800]!],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Today\'s Schedule',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_currentSchedule!.date.month}/${_currentSchedule!.date.day}/${_currentSchedule!.date.year}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Total Investment Value: \$${_currentSchedule!.totalSunkCostValue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Schedule Periods
                        ...List.generate(_currentSchedule!.periods.length, (index) {
                          final period = _currentSchedule!.periods[index];
                          final categoryColor = _getCategoryColor(period.sunkCost.category);
                          final percentage = (_currentSchedule!.totalSunkCostValue > 0)
                              ? (period.sunkCost.amount / _currentSchedule!.totalSunkCostValue * 100)
                              : 0.0;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: categoryColor.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Time
                                  Container(
                                    width: 80,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${period.startTime.hour.toString().padLeft(2, '0')}:${period.startTime.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: categoryColor,
                                          ),
                                        ),
                                        Text(
                                          'to',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: categoryColor.withOpacity(0.7),
                                          ),
                                        ),
                                        Text(
                                          '${period.endTime.hour.toString().padLeft(2, '0')}:${period.endTime.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: categoryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Activity Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          period.activity,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: categoryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                period.sunkCost.category,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: categoryColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '\$${period.sunkCost.amount.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '(${percentage.toStringAsFixed(1)}%)',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
