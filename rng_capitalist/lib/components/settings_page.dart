import 'package:flutter/material.dart';
import '../utils/format_utils.dart';

class SettingsPage extends StatelessWidget {
  final double strictnessLevel;
  final Function(double) onStrictnessChanged;
  final Function() onClearHistory;

  const SettingsPage({
    Key? key,
    required this.strictnessLevel,
    required this.onStrictnessChanged,
    required this.onClearHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF323130),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize your Oracle',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF605E5C),
            ),
          ),
          const SizedBox(height: 32),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Strictness Level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF323130),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adjust how strict the Oracle is with your spending decisions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF605E5C),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.sentiment_very_satisfied, color: Colors.green),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFF0078D4),
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: const Color(0xFF0078D4),
                          overlayColor: const Color(0xFF0078D4).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: strictnessLevel,
                          min: 0.0,
                          max: 3.0,
                          divisions: 30,
                          label: strictnessLevel == 0.0 ? 'OFF' : '${(strictnessLevel * 100).toStringAsFixed(0)}%',
                          onChanged: onStrictnessChanged,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    FormatUtils.getStrictnessDescription(strictnessLevel),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0078D4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF323130),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showClearHistoryDialog(context),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Clear History'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all your purchase history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onClearHistory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
