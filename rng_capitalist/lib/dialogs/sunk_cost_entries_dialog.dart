// lib/dialogs/sunk_cost_entries_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sunk_cost.dart';
import '../models/sunk_cost_entry.dart';
import 'add_sunk_cost_entry_dialog.dart';

class SunkCostEntriesDialog extends StatefulWidget {
  final SunkCost sunkCost;
  final Function(SunkCost) onSunkCostUpdated;

  const SunkCostEntriesDialog({
    Key? key,
    required this.sunkCost,
    required this.onSunkCostUpdated,
  }) : super(key: key);

  @override
  State<SunkCostEntriesDialog> createState() => _SunkCostEntriesDialogState();
}

class _SunkCostEntriesDialogState extends State<SunkCostEntriesDialog> {
  late SunkCost _currentSunkCost;

  @override
  void initState() {
    super.initState();
    _currentSunkCost = widget.sunkCost;
  }

  Future<void> _addEntry() async {
    final result = await showDialog<SunkCostEntry>(
      context: context,
      builder: (context) => AddSunkCostEntryDialog(
        sunkCostName: _currentSunkCost.name,
        suggestedCategory: _currentSunkCost.category,
        // Could pass templates here if needed
      ),
    );

    if (result != null) {
      setState(() {
        _currentSunkCost = _currentSunkCost.addEntry(result);
      });
      widget.onSunkCostUpdated(_currentSunkCost);
    }
  }

  Future<void> _deleteEntry(SunkCostEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete this \$${entry.amount.toStringAsFixed(2)} entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _currentSunkCost = _currentSunkCost.removeEntry(entry.id);
      });
      widget.onSunkCostUpdated(_currentSunkCost);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _currentSunkCost.entries..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 600,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_down, color: Colors.red[700], size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentSunkCost.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _currentSunkCost.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Base Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$${_currentSunkCost.baseAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Additional Entries',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$${_currentSunkCost.entriesAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$${_currentSunkCost.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add Entry Button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Entries',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _addEntry,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Entry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Entries List
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No additional entries yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add entries to track additional costs',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: entry.isAddition 
                                  ? Colors.green[100] 
                                  : Colors.red[100],
                              child: Icon(
                                entry.isAddition ? Icons.add : Icons.remove,
                                color: entry.isAddition 
                                    ? Colors.green[700] 
                                    : Colors.red[700],
                                size: 18,
                              ),
                            ),
                            title: Text(
                              entry.note,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entry.category != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.category!,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy at h:mm a').format(entry.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${entry.isAddition ? '+' : ''}\$${entry.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: entry.isAddition 
                                        ? Colors.green[700] 
                                        : Colors.red[700],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _deleteEntry(entry),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[400],
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
