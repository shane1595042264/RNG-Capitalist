// lib/main_dnd.dart
import 'package:flutter/material.dart';
import 'models/fixed_cost.dart';
import 'models/purchase_history.dart';
import 'models/dice_modifier.dart';
import 'utils/storage_utils_dnd.dart';
import 'components/oracle_page_dnd.dart';
import 'components/history_page.dart';
import 'components/fixed_costs_page.dart';
import 'components/modifiers_page.dart';
import 'components/about_page_dnd.dart';

void main() {
  runApp(const RNGCapitalistApp());
}

class RNGCapitalistApp extends StatelessWidget {
  const RNGCapitalistApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist - D&D Edition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers
  final _balanceController = TextEditingController();
  final _fixedCostsController = TextEditingController();
  final _priceController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _lastMonthSpendController = TextEditingController();
  final _availableBudgetController = TextEditingController();
  final _remainingBudgetController = TextEditingController();
  
  // State variables
  List<FixedCost> _fixedCosts = [];
  List<PurchaseHistory> _purchaseHistory = [];
  List<DiceModifier> _modifiers = [];
  double _lastMonthSpend = 0.0;
  String _currentPage = 'Oracle';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeDefaultModifiers();
  }
  
  void _initializeDefaultModifiers() {
    // Get all preset modifiers
    final presetModifiers = DiceModifier.getPresetModifiers();
    
    // If no saved modifiers, use presets
    if (_modifiers.isEmpty) {
      _modifiers = presetModifiers;
    } else {
      // Merge saved modifiers with presets, preserving saved states
      final mergedModifiers = <DiceModifier>[];
      
      // First, add all preset modifiers with saved states if available
      for (var preset in presetModifiers) {
        final saved = _modifiers.firstWhere(
          (m) => m.id == preset.id,
          orElse: () => preset,
        );
        mergedModifiers.add(preset.copyWith(
          isActive: saved.isActive,
          isUnlocked: saved.isUnlocked,
        ));
      }
      
      // Then add any custom modifiers not in presets
      final customModifiers = _modifiers.where((m) => 
        !presetModifiers.any((p) => p.id == m.id)
      ).toList();
      mergedModifiers.addAll(customModifiers);
      
      _modifiers = mergedModifiers;
    }
  }
  
  @override
  void dispose() {
    _balanceController.dispose();
    _fixedCostsController.dispose();
    _priceController.dispose();
    _itemNameController.dispose();
    _lastMonthSpendController.dispose();
    _availableBudgetController.dispose();
    _remainingBudgetController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final data = await StorageUtilsDnD.loadSettings();
    setState(() {
      _balanceController.text = data.lastBalance;
      _lastMonthSpend = data.lastMonthSpend;
      _fixedCosts = data.fixedCosts;
      _purchaseHistory = data.purchaseHistory;
      if (data.modifiers.isNotEmpty) {
        _modifiers = data.modifiers;
      }
    });
    _calculateTotalFixedCosts();
    _updateLastMonthSpendController();
  }

  Future<void> _saveSettings() async {
    final data = AppDataDnD(
      lastBalance: _balanceController.text,
      lastMonthSpend: _lastMonthSpend,
      fixedCosts: _fixedCosts,
      purchaseHistory: _purchaseHistory,
      modifiers: _modifiers,
    );
    await StorageUtilsDnD.saveSettings(data);
  }

  void _updateLastMonthSpendController() {
    _lastMonthSpendController.text = _lastMonthSpend.toStringAsFixed(2);
    _updateAvailableBudget();
  }
  
  void _updateAvailableBudget() {
    double currentBalance = double.tryParse(_balanceController.text) ?? 0.0;
    double availableBudget = currentBalance - _lastMonthSpend;
    _availableBudgetController.text = availableBudget.toStringAsFixed(2);
    _updateRemainingBudget();
  }
  
  void _updateRemainingBudget() {
    double availableBudget = double.tryParse(_availableBudgetController.text) ?? 0.0;
    double fixedCosts = double.tryParse(_fixedCostsController.text) ?? 0.0;
    double remainingBudget = availableBudget - fixedCosts;
    _remainingBudgetController.text = remainingBudget.toStringAsFixed(2);
  }

  void _calculateTotalFixedCosts() {
    double total = 0;
    for (var cost in _fixedCosts.where((c) => c.isActive)) {
      total += cost.amount;
    }
    _fixedCostsController.text = total.toStringAsFixed(2);
    _updateRemainingBudget();
  }

  void _navigateTo(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onPurchaseDecision(PurchaseHistory history) {
    setState(() {
      _purchaseHistory.insert(0, history);
      if (_purchaseHistory.length > 100) {
        _purchaseHistory.removeLast();
      }
    });
    _saveSettings();
  }

  void _onLastMonthSpendChanged(double value) {
    setState(() {
      _lastMonthSpend = value;
    });
    _saveSettings();
  }

  void _onToggleModifier(DiceModifier modifier) {
    setState(() {
      final index = _modifiers.indexWhere((m) => m.id == modifier.id);
      if (index != -1) {
        _modifiers[index] = modifier;
      } else {
        _modifiers.add(modifier);
      }
    });
    _saveSettings();
  }

  void _onAddModifier(DiceModifier modifier) {
    setState(() {
      _modifiers.add(modifier);
    });
    _saveSettings();
  }

  void _onDeleteModifier(String modifierId) {
    setState(() {
      _modifiers.removeWhere((m) => m.id == modifierId);
    });
    _saveSettings();
  }

  void _onAddFixedCost(FixedCost cost) {
    setState(() {
      _fixedCosts.add(cost);
      _calculateTotalFixedCosts();
    });
    _saveSettings();
  }

  void _onEditFixedCost(FixedCost updatedCost) {
    setState(() {
      final index = _fixedCosts.indexWhere((c) => c.id == updatedCost.id);
      if (index != -1) {
        _fixedCosts[index] = updatedCost;
        _calculateTotalFixedCosts();
      }
    });
    _saveSettings();
  }

  void _onDeleteFixedCost(String costId) {
    setState(() {
      _fixedCosts.removeWhere((c) => c.id == costId);
      _calculateTotalFixedCosts();
    });
    _saveSettings();
  }

  void _onToggleFixedCost(FixedCost cost, bool isActive) {
    setState(() {
      final index = _fixedCosts.indexOf(cost);
      _fixedCosts[index] = FixedCost(
        id: cost.id,
        name: cost.name,
        amount: cost.amount,
        category: cost.category,
        isActive: isActive,
      );
      _calculateTotalFixedCosts();
    });
    _saveSettings();
  }

  Widget _buildMainContent() {
    switch (_currentPage) {
      case 'Oracle':
        return OraclePageDnD(
          balanceController: _balanceController,
          fixedCostsController: _fixedCostsController,
          priceController: _priceController,
          itemNameController: _itemNameController,
          lastMonthSpendController: _lastMonthSpendController,
          availableBudgetController: _availableBudgetController,
          remainingBudgetController: _remainingBudgetController,
          lastMonthSpend: _lastMonthSpend,
          activeModifiers: _modifiers.where((m) => m.isActive).toList(),
          onNavigateTo: _navigateTo,
          onLastMonthSpendChanged: _onLastMonthSpendChanged,
          onPurchaseDecision: _onPurchaseDecision,
        );
      case 'History':
        return HistoryPage(purchaseHistory: _purchaseHistory);
      case 'Fixed Costs':
        return FixedCostsPage(
          fixedCosts: _fixedCosts,
          onAddCost: _onAddFixedCost,
          onEditCost: _onEditFixedCost,
          onDeleteCost: _onDeleteFixedCost,
          onToggleCost: _onToggleFixedCost,
        );
      case 'Modifiers':
        return ModifiersPage(
          userModifiers: _modifiers,
          onToggleModifier: _onToggleModifier,
          onAddModifier: _onAddModifier,
          onDeleteModifier: _onDeleteModifier,
        );
      case 'About':
        return const AboutPageDnD();
      default:
        return OraclePageDnD(
          balanceController: _balanceController,
          fixedCostsController: _fixedCostsController,
          priceController: _priceController,
          itemNameController: _itemNameController,
          lastMonthSpendController: _lastMonthSpendController,
          availableBudgetController: _availableBudgetController,
          remainingBudgetController: _remainingBudgetController,
          lastMonthSpend: _lastMonthSpend,
          activeModifiers: _modifiers.where((m) => m.isActive).toList(),
          onNavigateTo: _navigateTo,
          onLastMonthSpendChanged: _onLastMonthSpendChanged,
          onPurchaseDecision: _onPurchaseDecision,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Row(
        children: [
          AppSidebarDnD(
            currentPage: _currentPage,
            onNavigate: _navigateTo,
          ),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }
}

// lib/components/app_sidebar_dnd.dart
class AppSidebarDnD extends StatelessWidget {
  final String currentPage;
  final Function(String) onNavigate;

  const AppSidebarDnD({
    Key? key,
    required this.currentPage,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border(
          right: BorderSide(
            color: Colors.black.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // App Logo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[600]!, Colors.purple[800]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.casino,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RNG Capitalist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'D&D Edition',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNavItem(Icons.casino, 'Oracle', currentPage == 'Oracle'),
          _buildNavItem(Icons.history, 'History', currentPage == 'History'),
          _buildNavItem(Icons.account_balance_wallet, 'Fixed Costs', currentPage == 'Fixed Costs'),
          _buildNavItem(Icons.auto_awesome, 'Modifiers', currentPage == 'Modifiers'),
          const Spacer(),
          _buildNavItem(Icons.info_outline, 'About', currentPage == 'About'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.purple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.purple[700] : const Color(0xFF605E5C),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.purple[700] : const Color(0xFF323130),
          ),
        ),
        onTap: () => onNavigate(label),
      ),
    );
  }
}