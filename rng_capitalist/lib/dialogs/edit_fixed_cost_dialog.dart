import 'package:flutter/material.dart';
import '../models/fixed_cost.dart';

class EditFixedCostDialog extends StatefulWidget {
  final FixedCost cost;
  final Function(FixedCost) onEdit;

  const EditFixedCostDialog({
    Key? key,
    required this.cost,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<EditFixedCostDialog> createState() => _EditFixedCostDialogState();
}

class _EditFixedCostDialogState extends State<EditFixedCostDialog> {
  late final TextEditingController nameController;
  late final TextEditingController amountController;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.cost.name);
    amountController = TextEditingController(text: widget.cost.amount.toString());
    selectedCategory = widget.cost.category;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Fixed Cost'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g., Rent, Car Payment',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (\$)',
              hintText: '0.00',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
            ),
            items: ['Housing', 'Transportation', 'Food', 'Utilities', 'Insurance', 'Other']
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value ?? 'Other';
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            final amount = double.tryParse(amountController.text) ?? 0;
            
            if (name.isNotEmpty && amount > 0) {
              widget.onEdit(FixedCost(
                id: widget.cost.id,
                name: name,
                amount: amount,
                category: selectedCategory,
                isActive: widget.cost.isActive,
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
