// lib/dialogs/add_sunk_cost_entry_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sunk_cost_entry.dart';
import '../models/entry_template.dart';
import '../services/template_service.dart';
import 'manage_templates_dialog.dart';

class AddSunkCostEntryDialog extends StatefulWidget {
  final String sunkCostName;
  final String? suggestedCategory;
  final List<EntryTemplate>? templates;
  final Function(List<EntryTemplate>)? onTemplatesUpdated;
  final bool initialMode; // true for add, false for subtract

  const AddSunkCostEntryDialog({
    Key? key,
    required this.sunkCostName,
    this.suggestedCategory,
    this.templates,
    this.onTemplatesUpdated,
    this.initialMode = true, // Default to add mode
  }) : super(key: key);

  @override
  State<AddSunkCostEntryDialog> createState() => _AddSunkCostEntryDialogState();
}

class _AddSunkCostEntryDialogState extends State<AddSunkCostEntryDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isAddition = true; // true for addition, false for subtraction
  late List<EntryTemplate> _templates;

  @override
  void initState() {
    super.initState();
    if (widget.suggestedCategory != null) {
      _categoryController.text = widget.suggestedCategory!;
    }
    
    // Initialize templates and mode
    _templates = widget.templates ?? EntryTemplate.getDefaultTemplates();
    _isAddition = widget.initialMode; // Set initial mode from parameter
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _selectTemplate(EntryTemplate template) {
    setState(() {
      _noteController.text = template.description;
      if (template.amount != null) {
        _amountController.text = template.amount!.toStringAsFixed(2);
      }
      _isAddition = template.isAddition;
    });
  }

  void _manageTemplates() async {
    final result = await showDialog<List<EntryTemplate>>(
      context: context,
      builder: (context) => ManageTemplatesDialog(
        templates: _templates,
        userId: 'douvleplus', // In a real app, get this from auth service
        onTemplatesUpdated: (updatedTemplates) {
          // Update local templates immediately
          setState(() {
            _templates = updatedTemplates;
          });
          // Notify parent component
          if (widget.onTemplatesUpdated != null) {
            widget.onTemplatesUpdated!(updatedTemplates);
          }
        },
      ),
    );

    // Also handle the return value (though the callback above should handle most cases)
    if (result != null) {
      setState(() {
        _templates = result;
      });
      if (widget.onTemplatesUpdated != null) {
        widget.onTemplatesUpdated!(result);
      }
    } else {
      // Even if result is null, reload templates from Firebase to get latest changes
      try {
        final latestTemplates = await TemplateService.loadUserTemplates('douvleplus');
        setState(() {
          _templates = latestTemplates;
        });
        if (widget.onTemplatesUpdated != null) {
          widget.onTemplatesUpdated!(latestTemplates);
        }
      } catch (e) {
        print('Error reloading templates: $e');
      }
    }
  }

  void _addEntry() {
    final amountText = _amountController.text.trim();
    final note = _noteController.text.trim();
    final category = _categoryController.text.trim();

    if (amountText.isEmpty || note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill amount and note fields'),
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

    // Apply positive or negative amount based on operation type
    final finalAmount = _isAddition ? amount : -amount;

    final entry = SunkCostEntry(
      amount: finalAmount,
      note: note,
      category: category.isNotEmpty ? category : null,
    );

    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 650,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _isAddition ? Icons.add_circle : Icons.remove_circle,
                  color: _isAddition ? Colors.green[700] : Colors.red[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isAddition ? 'Add Entry' : 'Subtract Entry',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_isAddition ? 'Adding to' : 'Subtracting from'}: ${widget.sunkCostName}',
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
            const SizedBox(height: 24),

            // Add/Subtract Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAddition = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isAddition ? Colors.green[700] : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: _isAddition ? Colors.white : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add Amount',
                              style: TextStyle(
                                color: _isAddition ? Colors.white : Colors.grey[600],
                                fontWeight: _isAddition ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAddition = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isAddition ? Colors.red[700] : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove,
                              color: !_isAddition ? Colors.white : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Subtract Amount',
                              style: TextStyle(
                                color: !_isAddition ? Colors.white : Colors.grey[600],
                                fontWeight: !_isAddition ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: _isAddition ? 'Amount to Add' : 'Amount to Subtract',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '0.00',
                suffixIcon: Icon(
                  _isAddition ? Icons.trending_up : Icons.trending_down,
                  color: _isAddition ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Field (Optional)
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'e.g., Subscription, Refund, Correction',
              ),
            ),
            const SizedBox(height: 16),

            // Note Field
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Note/Memo *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Describe what this expense is for...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Templates Section
            Row(
              children: [
                const Text(
                  'Quick Templates:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _manageTemplates,
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Manage'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _templates.map((template) {
                    return ActionChip(
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          if (template.amount != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${template.isAddition ? '+' : '-'}\$${template.amount!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: template.isAddition ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      onPressed: () => _selectTemplate(template),
                      backgroundColor: template.isAddition 
                          ? (template.isDefault ? Colors.blue[50] : Colors.green[50])
                          : Colors.red[50],
                      side: BorderSide(
                        color: template.isAddition 
                            ? (template.isDefault ? Colors.blue[200]! : Colors.green[200]!)
                            : Colors.red[200]!,
                      ),
                      avatar: Icon(
                        template.isAddition ? Icons.add : Icons.remove,
                        size: 14,
                        color: template.isAddition 
                            ? (template.isDefault ? Colors.blue[600] : Colors.green[600])
                            : Colors.red[600],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addEntry,
                  icon: Icon(_isAddition ? Icons.add : Icons.remove),
                  label: Text(_isAddition ? 'Add Entry' : 'Subtract Entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAddition ? Colors.green[700] : Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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
