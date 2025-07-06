import 'package:flutter/material.dart';
import '../models/fixed_cost.dart';

class AddFixedCostDialog extends StatefulWidget {
  final Function(FixedCost) onAdd;

  const AddFixedCostDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddFixedCostDialog> createState() => _AddFixedCostDialogState();
}

class _AddFixedCostDialogState extends State<AddFixedCostDialog> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  String selectedCategory = 'Other';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Fixed Cost'),
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
              widget.onAdd(FixedCost(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                amount: amount,
                category: selectedCategory,
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
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
