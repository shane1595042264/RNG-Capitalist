import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/oracle_utils.dart';
import '../utils/format_utils.dart';

class OraclePage extends StatefulWidget {
  final TextEditingController balanceController;
  final TextEditingController fixedCostsController;
  final TextEditingController priceController;
  final TextEditingController itemNameController;
  final TextEditingController lastMonthSpendController;
  final TextEditingController availableBudgetController;
  final TextEditingController remainingBudgetController;
  final double lastMonthSpend;
  final double strictnessLevel;
  final Function(String) onNavigateTo;
  final Function(double) onLastMonthSpendChanged;
  final Function(DecisionResult) onOracleResult;
  final Function(double) onStrictnessChanged;

  const OraclePage({
    Key? key,
    required this.balanceController,
    required this.fixedCostsController,
    required this.priceController,
    required this.itemNameController,
    required this.lastMonthSpendController,
    required this.availableBudgetController,
    required this.remainingBudgetController,
    required this.lastMonthSpend,
    required this.strictnessLevel,
    required this.onNavigateTo,
    required this.onLastMonthSpendChanged,
    required this.onOracleResult,
    required this.onStrictnessChanged,
  }) : super(key: key);

  @override
  State<OraclePage> createState() => _OraclePageState();
}

class _OraclePageState extends State<OraclePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _showResult = false;
  DecisionResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _consultOracle() {
    final balance = double.tryParse(widget.balanceController.text) ?? 0;
    final fixedCosts = double.tryParse(widget.fixedCostsController.text) ?? 0;
    final price = double.tryParse(widget.priceController.text) ?? 0;
    final itemName = widget.itemNameController.text;
    
    final result = OracleUtils.consultOracle(
      balance: balance,
      fixedCosts: fixedCosts,
      price: price,
      itemName: itemName,
      lastMonthSpend: widget.lastMonthSpend,
      strictnessLevel: widget.strictnessLevel,
    );

    setState(() {
      _showResult = true;
      _lastResult = result;
    });

    widget.onOracleResult(result);
    _animationController.forward(from: 0);
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _updateAvailableBudget() {
    double currentBalance = double.tryParse(widget.balanceController.text) ?? 0.0;
    double availableBudget = currentBalance - widget.lastMonthSpend;
    widget.availableBudgetController.text = availableBudget.toStringAsFixed(2);
    _updateRemainingBudget();
  }
  
  void _updateRemainingBudget() {
    double availableBudget = double.tryParse(widget.availableBudgetController.text) ?? 0.0;
    double fixedCosts = double.tryParse(widget.fixedCostsController.text) ?? 0.0;
    double remainingBudget = availableBudget - fixedCosts;
    widget.remainingBudgetController.text = remainingBudget.toStringAsFixed(2);
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    bool readOnly = false,
    Color? backgroundColor,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF323130),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: label.contains('\$') 
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: backgroundColor != null,
            fillColor: backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF0078D4)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Consult the Oracle',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF323130),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let chaos manage your wallet',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF605E5C),
            ),
          ),
          const SizedBox(height: 32),
          
          // Input Card
          Container(
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
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  'Current Balance (\$)',
                  widget.balanceController,
                  '1000',
                  onChanged: (value) => _updateAvailableBudget(),
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  'Last Month Total Spend (\$)',
                  widget.lastMonthSpendController,
                  '0',
                  onChanged: (value) {
                    final newValue = double.tryParse(value) ?? 0.0;
                    widget.onLastMonthSpendChanged(newValue);
                    _updateAvailableBudget();
                  },
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  'Available Budget (\$)',
                  widget.availableBudgetController,
                  '1000',
                  readOnly: true,
                  backgroundColor: Colors.grey[100],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F3FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0078D4), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF0078D4), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Available Budget = Current Balance - Last Month Total Spend',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        'Monthly Fixed Costs (\$)',
                        widget.fixedCostsController,
                        '800',
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () => widget.onNavigateTo('Fixed Costs'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  'Remaining Budget (\$)',
                  widget.remainingBudgetController,
                  '200',
                  readOnly: true,
                  backgroundColor: Colors.green[50],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Remaining Budget = Available Budget - Monthly Fixed Costs',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  'Item Name (Optional)',
                  widget.itemNameController,
                  'That thing you want',
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  'Item Price (\$)',
                  widget.priceController,
                  '50',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _consultOracle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CONSULT THE ORACLE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Oracle Response
          if (_showResult && _lastResult != null)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(top: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _lastResult!.shouldBuy
                              ? [const Color(0xFF10C876), const Color(0xFF00B67A)]
                              : [const Color(0xFFE81123), const Color(0xFFC50E1F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: (_lastResult!.shouldBuy ? Colors.green : Colors.red).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            _lastResult!.shouldBuy ? Icons.celebration : Icons.block,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'The Oracle has spoken...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _lastResult!.decisionText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _lastResult!.explanationText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _lastResult!.statsText,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontFamily: 'Consolas',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 32),
          
          // Strictness Control
          Container(
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
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Strictness Level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF323130),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  FormatUtils.getStrictnessDescription(widget.strictnessLevel),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF605E5C),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('0%', style: TextStyle(fontSize: 12, color: Color(0xFF605E5C))),
                    Expanded(
                      child: Slider(
                        value: widget.strictnessLevel,
                        min: 0.0,
                        max: 3.0,
                        divisions: 30,
                        onChanged: widget.onStrictnessChanged,
                      ),
                    ),
                    const Text('300%', style: TextStyle(fontSize: 12, color: Color(0xFF605E5C))),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'How It Works',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Threshold = Strictness × (Price ÷ Remaining Budget)\n'
                        '• 100% = Pure price ratio (balanced)\n'
                        '• 0% = Always approve purchases\n'
                        '• 300% = Maximum resistance to spending',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
