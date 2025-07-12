// lib/components/sunk_costs_page.dart
import 'package:flutter/material.dart';
import '../models/sunk_cost.dart';
import '../dialogs/add_sunk_cost_dialog.dart';
import '../dialogs/edit_sunk_cost_dialog.dart';
import '../dialogs/upload_sunk_cost_dialog.dart';

class SunkCostsPage extends StatefulWidget {
  final List<SunkCost> sunkCosts;
  final Function(SunkCost) onAddCost;
  final Function(SunkCost) onEditCost;
  final Function(String) onDeleteCost;
  final Function(SunkCost, bool) onToggleCost;

  const SunkCostsPage({
    Key? key,
    required this.sunkCosts,
    required this.onAddCost,
    required this.onEditCost,
    required this.onDeleteCost,
    required this.onToggleCost,
  }) : super(key: key);

  @override
  State<SunkCostsPage> createState() => _SunkCostsPageState();
}

class _SunkCostsPageState extends State<SunkCostsPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<String> get _categories {
    final categories = widget.sunkCosts
        .map((cost) => cost.category)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...categories];
  }

  List<SunkCost> get _filteredCosts {
    return widget.sunkCosts.where((cost) {
      final matchesCategory = _selectedCategory == 'All' || cost.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          cost.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cost.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  double get _totalSunkCostValue {
    return widget.sunkCosts
        .where((cost) => cost.isActive)
        .fold(0.0, (sum, cost) => sum + cost.amount);
  }

  Map<String, double> get _categoryTotals {
    final totals = <String, double>{};
    for (var cost in widget.sunkCosts.where((c) => c.isActive)) {
      totals[cost.category] = (totals[cost.category] ?? 0) + cost.amount;
    }
    return totals;
  }

  Future<void> _showAddCostDialog() async {
    final existingCategories = widget.sunkCosts
        .map((cost) => cost.category)
        .toSet()
        .toList()
      ..sort();

    final result = await showDialog<SunkCost>(
      context: context,
      builder: (context) => AddSunkCostDialog(
        existingCategories: existingCategories,
      ),
    );

    if (result != null) {
      widget.onAddCost(result);
    }
  }

  Future<void> _showEditCostDialog(SunkCost cost) async {
    final existingCategories = widget.sunkCosts
        .map((c) => c.category)
        .toSet()
        .toList()
      ..sort();

    final result = await showDialog<SunkCost>(
      context: context,
      builder: (context) => EditSunkCostDialog(
        sunkCost: cost,
        existingCategories: existingCategories,
      ),
    );

    if (result != null) {
      widget.onEditCost(result);
    }
  }

  Future<void> _showUploadDialog() async {
    final existingCategories = widget.sunkCosts
        .map((cost) => cost.category)
        .toSet()
        .toList()
      ..sort();

    final result = await showDialog<List<SunkCost>>(
      context: context,
      builder: (context) => UploadSunkCostDialog(
        existingCategories: existingCategories,
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Add each extracted sunk cost
      for (final cost in result) {
        widget.onAddCost(cost);
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${result.length} sunk cost${result.length > 1 ? 's' : ''} from document'),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(SunkCost cost) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sunk Cost'),
        content: Text('Are you sure you want to delete "${cost.name}"?'),
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
      widget.onDeleteCost(cost.id);
    }
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
                      Icons.trending_down,
                      color: Colors.red[700],
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sunk Cost Recovery',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: _showUploadDialog,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('AI Upload'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple[700],
                        side: BorderSide(color: Colors.purple[700]!),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _showAddCostDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Sunk Cost'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
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
                  'Track your investments and generate time schedules based on sunk cost value to maximize recovery.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Sunk Cost Value',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${_totalSunkCostValue.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Investments',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.sunkCosts.where((c) => c.isActive).length}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
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
          
          // Filters and Search
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search sunk costs...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    underline: const SizedBox(),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Sunk Costs List
          Expanded(
            child: _filteredCosts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_down,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No sunk costs found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first sunk cost to start tracking',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCosts.length,
                    itemBuilder: (context, index) {
                      final cost = _filteredCosts[index];
                      final percentage = _totalSunkCostValue > 0 
                          ? (cost.amount / _totalSunkCostValue * 100)
                          : 0.0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: cost.isActive 
                                ? Colors.red[100] 
                                : Colors.grey[200],
                            child: Icon(
                              Icons.trending_down,
                              color: cost.isActive 
                                  ? Colors.red[700] 
                                  : Colors.grey[500],
                            ),
                          ),
                          title: Text(
                            cost.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: cost.isActive 
                                  ? Colors.black87 
                                  : Colors.grey[600],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                cost.category,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              if (cost.isActive) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${percentage.toStringAsFixed(1)}% of total',
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${cost.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: cost.isActive 
                                      ? Colors.red[700] 
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: cost.isActive,
                                onChanged: (value) {
                                  widget.onToggleCost(cost, value);
                                },
                                activeColor: Colors.red[700],
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _showEditCostDialog(cost);
                                      break;
                                    case 'delete':
                                      _confirmDelete(cost);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 16, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
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
    );
  }
}
