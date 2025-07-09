// lib/components/oracle_page_dnd.dart
import 'package:flutter/material.dart';
import '../models/dice_modifier.dart';
import '../models/purchase_history.dart';
import '../utils/format_utils.dart';
import 'dice_roll_overlay.dart';

class OraclePageDnD extends StatefulWidget {
  final TextEditingController balanceController;
  final TextEditingController fixedCostsController;
  final TextEditingController priceController;
  final TextEditingController itemNameController;
  final TextEditingController lastMonthSpendController;
  final TextEditingController availableBudgetController;
  final TextEditingController remainingBudgetController;
  final double lastMonthSpend;
  final List<DiceModifier> activeModifiers;
  final List<PurchaseHistory> purchaseHistory;
  final Function(String) onNavigateTo;
  final Function(double) onLastMonthSpendChanged;
  final Function(PurchaseHistory) onPurchaseDecision;

  const OraclePageDnD({
    Key? key,
    required this.balanceController,
    required this.fixedCostsController,
    required this.priceController,
    required this.itemNameController,
    required this.lastMonthSpendController,
    required this.availableBudgetController,
    required this.remainingBudgetController,
    required this.lastMonthSpend,
    required this.activeModifiers,
    required this.purchaseHistory,
    required this.onNavigateTo,
    required this.onLastMonthSpendChanged,
    required this.onPurchaseDecision,
  }) : super(key: key);

  @override
  State<OraclePageDnD> createState() => _OraclePageDnDState();
}

class _OraclePageDnDState extends State<OraclePageDnD> {
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

  void _rollForPurchase() {
    final price = double.tryParse(widget.priceController.text) ?? 0;
    final remainingBudget = double.tryParse(widget.remainingBudgetController.text) ?? 0;
    final itemName = widget.itemNameController.text.isEmpty ? 'Unknown Item' : widget.itemNameController.text;
    
    // Validation
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }
    
    if (remainingBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No remaining budget available!')),
      );
      return;
    }
    
    // Check for cooldown on this item
    final cooldownItem = widget.purchaseHistory.firstWhere(
      (item) => item.itemName.toLowerCase() == itemName.toLowerCase() && 
                item.isOnCooldown,
      orElse: () => PurchaseHistory(
        id: '',
        itemName: '',
        price: 0,
        date: DateTime.now(),
        wasPurchased: true,
        threshold: 0,
        rollValue: 0,
      ),
    );
    
    if (cooldownItem.id.isNotEmpty) {
      final cooldownDuration = cooldownItem.remainingCooldown!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Item "$itemName" is on cooldown! ${FormatUtils.formatCooldownStatus(cooldownDuration)}',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    
    // Show dice roll overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DiceRollOverlay(
        itemName: itemName,
        itemPrice: price,
        availableBudget: remainingBudget,
        activeModifiers: widget.activeModifiers,
        onRollComplete: (success, roll, threshold, total) {
          // Create purchase history with cooldown for rejected items
          final availableBudget = double.tryParse(widget.availableBudgetController.text) ?? 0.0;
          final history = PurchaseHistory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            itemName: itemName,
            price: price,
            date: DateTime.now(),
            wasPurchased: success,
            threshold: threshold.toDouble(),
            rollValue: total.toDouble(),
            availableBudget: availableBudget,
            cooldownUntil: success ? null : PurchaseHistory.calculateCooldownUntil(price, availableBudget),
          );
          
          widget.onPurchaseDecision(history);
          Navigator.pop(context);
          
          // Show result message with cooldown info for rejected items
          String message = success 
              ? '🎉 Purchase approved! You rolled $total vs DC $threshold'
              : '❌ Purchase denied! You rolled $total vs DC $threshold';
          
          if (!success && history.cooldownUntil != null) {
            final cooldownDuration = history.cooldownUntil!.difference(DateTime.now());
            message += '\nCooldown: ${FormatUtils.formatCooldownDuration(cooldownDuration)}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: success ? Colors.green : Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      ),
    );
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
            'Roll for Purchase',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF323130),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let the dice decide your financial fate',
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
                const SizedBox(height: 24),
                _buildInputField(
                  'Item Name',
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
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _rollForPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.casino, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'ROLL FOR PURCHASE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Active Modifiers Display
          if (widget.activeModifiers.isNotEmpty)
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Active Modifiers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF323130),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => widget.onNavigateTo('Modifiers'),
                        icon: const Icon(Icons.edit),
                        label: const Text('Manage'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: widget.activeModifiers.map((modifier) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber[600]!,
                              Colors.amber[700]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              modifier.icon,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${modifier.name} ${modifier.value >= 0 ? '+' : ''}${modifier.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total modifier: ${widget.activeModifiers.fold(0, (sum, mod) => sum + mod.value) >= 0 ? '+' : ''}${widget.activeModifiers.fold(0, (sum, mod) => sum + mod.value)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          
          // D&D Mechanics Info
          Container(
            margin: const EdgeInsets.only(top: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎲 How the Dice Work',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Difficulty Class (DC) = (Item Price ÷ Remaining Budget) × 20\n'
                  'Roll: 1d20 + modifiers\n'
                  'If roll ≥ DC → Purchase approved!\n\n'
                  'Example: \$50 item with \$200 budget = DC 5 (easy)\n'
                  'Example: \$150 item with \$200 budget = DC 15 (hard)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
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