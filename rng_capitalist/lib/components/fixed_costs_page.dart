import 'package:flutter/material.dart';
import '../models/fixed_cost.dart';
import '../dialogs/add_fixed_cost_dialog.dart';
import '../dialogs/edit_fixed_cost_dialog.dart';

class FixedCostsPage extends StatelessWidget {
  final List<FixedCost> fixedCosts;
  final Function(FixedCost) onAddCost;
  final Function(FixedCost) onEditCost;
  final Function(String) onDeleteCost;
  final Function(FixedCost, bool) onToggleCost;

  const FixedCostsPage({
    Key? key,
    required this.fixedCosts,
    required this.onAddCost,
    required this.onEditCost,
    required this.onDeleteCost,
    required this.onToggleCost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = ['Housing', 'Transportation', 'Food', 'Utilities', 'Insurance', 'Other'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Fixed Monthly Costs',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF323130),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Cost'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0078D4),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total: \$${fixedCosts.where((c) => c.isActive).fold(0.0, (sum, cost) => sum + cost.amount).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF605E5C),
            ),
          ),
          const SizedBox(height: 32),
          
          if (fixedCosts.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
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
              child: const Center(
                child: Text(
                  'No fixed costs added yet. Click "Add Cost" to get started!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF605E5C),
                  ),
                ),
              ),
            )
          else
            ...categories.map((category) {
              final costsInCategory = fixedCosts.where((c) => c.category == category).toList();
              if (costsInCategory.isEmpty) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF323130),
                      ),
                    ),
                  ),
                  ...costsInCategory.map((cost) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: cost.isActive,
                        onChanged: (value) => onToggleCost(cost, value ?? true),
                      ),
                      title: Text(
                        cost.name,
                        style: TextStyle(
                          decoration: cost.isActive ? null : TextDecoration.lineThrough,
                          color: cost.isActive ? null : Colors.grey,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${cost.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cost.isActive ? const Color(0xFF323130) : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditDialog(context, cost),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => onDeleteCost(cost.id),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddFixedCostDialog(
        onAdd: onAddCost,
      ),
    );
  }

  void _showEditDialog(BuildContext context, FixedCost cost) {
    showDialog(
      context: context,
      builder: (context) => EditFixedCostDialog(
        cost: cost,
        onEdit: onEditCost,
      ),
    );
  }
}
