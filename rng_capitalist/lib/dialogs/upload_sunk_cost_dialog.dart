// lib/dialogs/upload_sunk_cost_dialog.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/sunk_cost.dart';
import '../services/ai_document_service.dart'; // Real AI-powered service

class UploadSunkCostDialog extends StatefulWidget {
  final List<String> existingCategories;

  const UploadSunkCostDialog({
    Key? key,
    required this.existingCategories,
  }) : super(key: key);

  @override
  State<UploadSunkCostDialog> createState() => _UploadSunkCostDialogState();
}

class _UploadSunkCostDialogState extends State<UploadSunkCostDialog> {
  late final AIDocumentService _documentAI; // Real AI-powered service
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _documentAI = AIDocumentService(); // Real AI-powered service
  }
  
  bool _isProcessing = false;
  List<SunkCost> _extractedCosts = [];
  List<bool> _selectedCosts = [];
  String _processingStatus = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 700,
        child: Column(
          children: [
            // Fixed Header
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
                  Icon(Icons.smart_toy, color: Colors.purple[700], size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI-Powered Sunk Cost Upload',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload receipts, invoices, bank statements, or screenshots. Our AI will automatically extract sunk cost information.',
                          style: TextStyle(
                            fontSize: 16,
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
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isProcessing && _extractedCosts.isEmpty)
                      _buildUploadOptions()
                    else if (_isProcessing)
                      _buildProcessingView()
                    else
                      _buildResultsView(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOptions() {
    return Column(
      children: [
        // Upload Methods
        Row(
          children: [
            Expanded(
              child: _buildUploadCard(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Camera capture of receipts or documents',
                color: Colors.blue,
                onTap: _takePhoto,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildUploadCard(
                icon: Icons.photo_library,
                title: 'Upload Image',
                subtitle: 'Gallery photos or screenshots',
                color: Colors.green,
                onTap: _pickImage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildUploadCard(
                icon: Icons.picture_as_pdf,
                title: 'Upload PDF',
                subtitle: 'Bank statements, invoices, receipts',
                color: Colors.red,
                onTap: _pickPDF,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildUploadCard(
                icon: Icons.folder_open,
                title: 'Browse Images',
                subtitle: 'Any supported image format',
                color: Colors.orange,
                onTap: _pickAnyFile,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // AI Features
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.purple[700]),
                  const SizedBox(width: 8),
                  Text(
                    'AI-Powered Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(Icons.receipt_long, 'Smart OCR', 'Extracts text from any image or PDF'),
              _buildFeatureRow(Icons.smart_toy, 'Google Gemini AI', 'Real AI understands document context'),
              _buildFeatureRow(Icons.category, 'AI Categorization', 'Intelligently categorizes all expenses'),
              _buildFeatureRow(Icons.price_change, 'AI Amount Detection', r'Finds and parses complex amounts like $1,124.22'),
              _buildFeatureRow(Icons.account_balance, 'Bank Analysis', 'AI analyzes bank statement transactions'),
              _buildFeatureRow(Icons.local_offer, 'Smart Deduplication', 'AI prevents duplicate entries'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI Processing Document...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _processingStatus,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'AI Analysis Steps:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text('• Extracting text using ML Kit OCR'),
                Text('• Sending to Google Gemini AI'),
                Text('• AI analyzing document context'),
                Text('• AI detecting amounts and expenses'),
                Text('• AI categorizing transactions'),
                Text('• AI generating descriptions'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Header
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text(
              'Found ${_extractedCosts.length} Sunk Costs',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _resetDialog,
              child: const Text('Upload Another'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Selection Controls
        Row(
          children: [
            TextButton.icon(
              onPressed: _selectAll,
              icon: const Icon(Icons.select_all),
              label: const Text('Select All'),
            ),
            TextButton.icon(
              onPressed: _deselectAll,
              icon: const Icon(Icons.deselect),
              label: const Text('Deselect All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Results List
        Container(
          height: 300,
          child: ListView.builder(
            itemCount: _extractedCosts.length,
            itemBuilder: (context, index) {
              final cost = _extractedCosts[index];
              final isSelected = _selectedCosts[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      _selectedCosts[index] = value ?? false;
                    });
                  },
                  title: Text(
                    cost.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: \$${cost.amount.toStringAsFixed(2)}'),
                      Text('Category: ${cost.category}'),
                    ],
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.trending_down,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Action Buttons
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedCosts.any((selected) => selected)
                    ? _addSelectedCosts
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Add ${_selectedCosts.where((s) => s).length} Sunk Costs',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        await _processFile(photo.path);
      }
    } catch (e) {
      _showError('Error taking photo: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processFile(image.path);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        await _processFile(result.files.single.path!);
      }
    } catch (e) {
      _showError('Error picking PDF: $e');
    }
  }

  Future<void> _pickAnyFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'bmp', 'gif'],
      );

      if (result != null && result.files.single.path != null) {
        await _processFile(result.files.single.path!);
      }
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  Future<void> _processFile(String filePath) async {
    setState(() {
      _isProcessing = true;
      _processingStatus = 'Initializing AI analysis...';
    });

    try {
      setState(() {
        _processingStatus = 'Extracting text from document...';
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _processingStatus = 'Sending to Google Gemini AI...';
      });
      
      final extractedCosts = await _documentAI.analyzeDocument(filePath);
      
      setState(() {
        _processingStatus = 'AI analyzing and categorizing...';
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isProcessing = false;
        _extractedCosts = extractedCosts;
        _selectedCosts = List.filled(extractedCosts.length, true);
      });

      if (extractedCosts.isEmpty) {
        _showError('No sunk costs found in the document. Try a different file or check if it contains purchase information.');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Error processing document: $e');
    }
  }

  void _selectAll() {
    setState(() {
      _selectedCosts = List.filled(_extractedCosts.length, true);
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedCosts = List.filled(_extractedCosts.length, false);
    });
  }

  void _addSelectedCosts() {
    final selectedCosts = <SunkCost>[];
    for (int i = 0; i < _extractedCosts.length; i++) {
      if (_selectedCosts[i]) {
        selectedCosts.add(_extractedCosts[i]);
      }
    }
    
    Navigator.of(context).pop(selectedCosts);
  }

  void _resetDialog() {
    setState(() {
      _extractedCosts.clear();
      _selectedCosts.clear();
      _isProcessing = false;
      _processingStatus = '';
    });
  }

  void _showError(String message) {
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
}
