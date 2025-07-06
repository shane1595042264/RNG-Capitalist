// lib/dialogs/add_sunk_cost_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sunk_cost.dart';

class AddSunkCostDialog extends StatefulWidget {
  final List<String> existingCategories;

  const AddSunkCostDialog({
    Key? key,
    required this.existingCategories,
  }) : super(key: key);

  @override
  State<AddSunkCostDialog> createState() => _AddSunkCostDialogState();
}

class _AddSunkCostDialogState extends State<AddSunkCostDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _addSunkCost() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    final category = _selectedCategory ?? _categoryController.text.trim();

    if (name.isEmpty || amountText.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sunkCost = SunkCost(
      name: name,
      amount: amount,
      category: category,
    );

    Navigator.of(context).pop(sunkCost);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_down,
                  color: Colors.red[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Sunk Cost',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Investment/Purchase Name',
                hintText: 'e.g., College Tuition, Elden Ring, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 16),
            
            // Amount field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount (\$)',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            
            // Category dropdown/field
            if (widget.existingCategories.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                hint: const Text('Select or create category'),
                items: [
                  ...widget.existingCategories.map((category) => 
                    DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  ),
                  const DropdownMenuItem(
                    value: null,
                    child: Text('+ Add new category'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
            
            // Custom category field (shown when needed)
            if (_selectedCategory == null || widget.existingCategories.isEmpty)
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'New Category',
                  hintText: 'e.g., Education, Gaming, Hobbies',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.create_new_folder_outlined),
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addSunkCost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add Sunk Cost'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
