// lib/dialogs/manage_templates_dialog.dart
import 'package:flutter/material.dart';
import '../models/entry_template.dart';
import '../services/template_service.dart';

class ManageTemplatesDialog extends StatefulWidget {
  final List<EntryTemplate> templates;
  final Function(List<EntryTemplate>) onTemplatesUpdated;
  final String? userId; // Add user ID for Firebase integration

  const ManageTemplatesDialog({
    Key? key,
    required this.templates,
    required this.onTemplatesUpdated,
    this.userId,
  }) : super(key: key);

  @override
  State<ManageTemplatesDialog> createState() => _ManageTemplatesDialogState();
}

class _ManageTemplatesDialogState extends State<ManageTemplatesDialog> {
  late List<EntryTemplate> _templates;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isAddition = true;

  @override
  void initState() {
    super.initState();
    _templates = List.from(widget.templates);
    print('🔧 DEBUG: ManageTemplatesDialog initState - received ${widget.templates.length} templates');
    print('🔧 DEBUG: Template names: ${widget.templates.map((t) => t.name).toList()}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addTemplate() {
    print('🔧 DEBUG: _addTemplate called');
    print('🔧 DEBUG: Current _templates count: ${_templates.length}');
    print('🔧 DEBUG: Name field: "${_nameController.text.trim()}"');
    print('🔧 DEBUG: Description field: "${_descriptionController.text.trim()}"');
    
    if (_nameController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      print('🔧 DEBUG: Validation failed - empty fields');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both name and description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amountText = _amountController.text.trim();
    double? amount;
    if (amountText.isNotEmpty) {
      amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        print('🔧 DEBUG: Validation failed - invalid amount');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount or leave blank'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    print('🔧 DEBUG: Validation passed, creating template...');

    final newTemplate = EntryTemplate(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: amount,
      isAddition: _isAddition,
    );

    print('🔧 DEBUG: Created new template: ${newTemplate.name}');
    print('🔧 DEBUG: New template JSON: ${newTemplate.toJson()}');

    setState(() {
      _templates.add(newTemplate);
      _nameController.clear();
      _descriptionController.clear();
      _amountController.clear();
      _isAddition = true; // Reset to default
    });

    print('🔧 DEBUG: After adding, _templates count: ${_templates.length}');
    print('🔧 DEBUG: Template names: ${_templates.map((t) => t.name).toList()}');

    _saveTemplates();
  }

  Future<void> _saveTemplates() async {
    print('🔧 DEBUG: _saveTemplates called with ${_templates.length} templates');
    print('🔧 DEBUG: Template names before save: ${_templates.map((t) => t.name).toList()}');
    
    // Always notify parent of updates
    widget.onTemplatesUpdated(_templates);
    
    if (widget.userId != null) {
      try {
        await TemplateService.saveUserTemplates(widget.userId!, _templates);
        
        // Don't reload from database - trust our local state since we just saved it
        // This prevents newly added templates from being lost
        
        // Notify parent with current templates
        widget.onTemplatesUpdated(_templates);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Templates saved to cloud'),
              backgroundColor: Colors.green[700],
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save templates: $e'),
              backgroundColor: Colors.red[700],
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _editTemplate(EntryTemplate template) {
    _nameController.text = template.name;
    _descriptionController.text = template.description;
    _amountController.text = template.amount?.toStringAsFixed(2) ?? '';
    _isAddition = template.isAddition;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (Optional)',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                    hintText: 'Leave blank for no preset amount',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
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
                          onTap: () => setDialogState(() => _isAddition = true),
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
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Add',
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
                          onTap: () => setDialogState(() => _isAddition = false),
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
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Subtract',
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _nameController.clear();
                _descriptionController.clear();
                _amountController.clear();
                _isAddition = true;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty && 
                    _descriptionController.text.trim().isNotEmpty) {
                  
                  final amountText = _amountController.text.trim();
                  double? amount;
                  if (amountText.isNotEmpty) {
                    amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid amount or leave blank'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                  }

                  setState(() {
                    final index = _templates.indexWhere((t) => t.id == template.id);
                    if (index != -1) {
                      _templates[index] = template.copyWith(
                        name: _nameController.text.trim(),
                        description: _descriptionController.text.trim(),
                        amount: amount,
                        isAddition: _isAddition,
                      );
                    }
                  });
                  _nameController.clear();
                  _descriptionController.clear();
                  _amountController.clear();
                  _isAddition = true;
                  Navigator.of(context).pop();
                  _saveTemplates();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTemplate(EntryTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _templates.removeWhere((t) => t.id == template.id);
              });
              Navigator.of(context).pop();
              _saveTemplates();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveAndClose() async {
    // Save to database first
    await _saveTemplates();
    // Then close dialog
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 700,
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
              child: Row(
                children: [
                  Icon(Icons.tune, color: Colors.blue[700], size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Manage Templates',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Quick clear button for debugging
                  if (widget.userId == 'douvleplus') ...[
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          _templates.clear();
                        });
                        await _saveTemplates();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All templates cleared!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      child: const Text('Clear All'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Add Template Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Template',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Template Name and Description Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Template Name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Amount and Operation Type Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount (Optional)',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'e.g., 1200.00',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isAddition = true),
                                  child: Container(
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
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Add',
                                          style: TextStyle(
                                            color: _isAddition ? Colors.white : Colors.grey[600],
                                            fontWeight: _isAddition ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 12,
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
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Sub',
                                          style: TextStyle(
                                            color: !_isAddition ? Colors.white : Colors.grey[600],
                                            fontWeight: !_isAddition ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 12,
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
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          print('🔧 DEBUG: GREEN + BUTTON PRESSED!');
                          _addTemplate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Templates List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: template.isAddition
                            ? (template.isDefault ? Colors.blue[100] : Colors.green[100])
                            : Colors.red[100],
                        child: Icon(
                          template.isAddition ? Icons.add : Icons.remove,
                          color: template.isAddition
                              ? (template.isDefault ? Colors.blue[700] : Colors.green[700])
                              : Colors.red[700],
                          size: 18,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              template.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (template.amount != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: template.isAddition ? Colors.green[50] : Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: template.isAddition ? Colors.green[200]! : Colors.red[200]!,
                                ),
                              ),
                              child: Text(
                                '${template.isAddition ? '+' : '-'}\$${template.amount!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: template.isAddition ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(template.description),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (template.isDefault) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: template.isAddition ? Colors.green[50] : Colors.red[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  template.isAddition ? 'Add Operation' : 'Subtract Operation',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: template.isAddition ? Colors.green[700] : Colors.red[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!template.isDefault) ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: () => _editTemplate(template),
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                  tooltip: 'Edit Template',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: () => _deleteTemplate(template),
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[700],
                                    size: 20,
                                  ),
                                  tooltip: 'Delete Template',
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Protected',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_templates.length} templates',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saveAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save & Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
