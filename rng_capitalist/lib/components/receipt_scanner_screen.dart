// lib/components/receipt_scanner_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/smart_expense.dart';
import '../services/receipt_scanner_service.dart';
import '../models/expense_category.dart';

class ReceiptScannerScreen extends StatefulWidget {
  final Function(SmartExpense)? onExpenseAdded;

  const ReceiptScannerScreen({
    super.key,
    this.onExpenseAdded,
  });

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final ReceiptScannerService _scannerService = ReceiptScannerService();
  
  bool _isScanning = false;
  SmartExpense? _scannedExpense;
  String? _selectedImagePath;
  
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  ExpenseCategory? _selectedCategory;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _isScanning = true;
        });

        await _scanReceipt(image.path);
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _scanReceipt(String imagePath) async {
    try {
      final scannedExpense = await _scannerService.scanReceiptFromPath(imagePath);
      
      setState(() {
        _isScanning = false;
        _scannedExpense = scannedExpense;
        
        if (scannedExpense != null) {
          _descriptionController.text = scannedExpense.description;
          _amountController.text = scannedExpense.amount.toString();
          _selectedCategory = scannedExpense.category;
          _notesController.text = scannedExpense.notes ?? '';
        }
      });

      if (scannedExpense == null) {
        _showErrorDialog('Could not extract expense information from the receipt. Please enter details manually.');
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showErrorDialog('Failed to scan receipt: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveExpense() {
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) {
      _showErrorDialog('Please fill in description and amount');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorDialog('Please enter a valid amount');
      return;
    }

    final expense = SmartExpense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: _descriptionController.text,
      amount: amount,
      date: DateTime.now(),
      receiptImagePath: _selectedImagePath,
      category: _selectedCategory ?? DnDCategories.generalExpenses,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      metadata: _scannedExpense?.metadata ?? {},
      confidence: _scannedExpense?.confidence ?? 1.0,
    );

    widget.onExpenseAdded?.call(expense);
    Navigator.of(context).pop();
  }

  Widget _buildImagePicker() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan Receipt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take a photo or select from gallery to automatically extract expense details',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPreview() {
    if (_selectedImagePath == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receipt Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_selectedImagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (_isScanning) ...[
              const SizedBox(height: 16),
              const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Scanning receipt...'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Expense Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_scannedExpense != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Auto-detected (${(_scannedExpense!.confidence * 100).toStringAsFixed(0)}% confidence)',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: DnDCategories.getAllCategories().map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(category.name),
                      if (category.isDnDRelated) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.casino, size: 16, color: Colors.purple),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _saveExpense,
                icon: const Icon(Icons.save),
                label: const Text('Save Expense'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_selectedImagePath == null) _buildImagePicker(),
            if (_selectedImagePath != null) ...[
              _buildReceiptPreview(),
              const SizedBox(height: 16),
              _buildExpenseForm(),
            ],
          ],
        ),
      ),
    );
  }
}
