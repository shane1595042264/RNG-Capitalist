import 'package:flutter/material.dart';
import 'models/fixed_cost.dart';
import 'models/purchase_history.dart';
import 'utils/storage_utils.dart';
import 'utils/oracle_utils.dart';
import 'components/app_sidebar.dart';
import 'components/oracle_page.dart';
import 'components/history_page.dart';
import 'components/fixed_costs_page.dart';
import 'components/settings_page.dart';
import 'components/about_page.dart';

void main() {
  runApp(const RNGCapitalistApp());
}

class RNGCapitalistApp extends StatelessWidget {
  const RNGCapitalistApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0078D4),
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
  double _strictnessLevel = 1.0;
  List<FixedCost> _fixedCosts = [];
  List<PurchaseHistory> _purchaseHistory = [];
  double _lastMonthSpend = 0.0;
  String _currentPage = 'Oracle';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
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
    final data = await StorageUtils.loadSettings();
    setState(() {
      _strictnessLevel = data.strictnessLevel;
      _balanceController.text = data.lastBalance;
      _lastMonthSpend = data.lastMonthSpend;
      _fixedCosts = data.fixedCosts;
      _purchaseHistory = data.purchaseHistory;
    });
    _calculateTotalFixedCosts();
    _updateLastMonthSpendController();
  }

  Future<void> _saveSettings() async {
    final data = AppData(
      strictnessLevel: _strictnessLevel,
      lastBalance: _balanceController.text,
      lastMonthSpend: _lastMonthSpend,
      fixedCosts: _fixedCosts,
      purchaseHistory: _purchaseHistory,
    );
    await StorageUtils.saveSettings(data);
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

  void _onOracleResult(DecisionResult result) {
    setState(() {
      _purchaseHistory.insert(0, result.historyItem);
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

  void _onStrictnessChanged(double value) {
    setState(() {
      _strictnessLevel = value;
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

  void _onClearHistory() {
    setState(() {
      _purchaseHistory.clear();
    });
    _saveSettings();
  }

  Widget _buildMainContent() {
    switch (_currentPage) {
      case 'Oracle':
        return OraclePage(
          balanceController: _balanceController,
          fixedCostsController: _fixedCostsController,
          priceController: _priceController,
          itemNameController: _itemNameController,
          lastMonthSpendController: _lastMonthSpendController,
          availableBudgetController: _availableBudgetController,
          remainingBudgetController: _remainingBudgetController,
          lastMonthSpend: _lastMonthSpend,
          strictnessLevel: _strictnessLevel,
          onNavigateTo: _navigateTo,
          onLastMonthSpendChanged: _onLastMonthSpendChanged,
          onOracleResult: _onOracleResult,
          onStrictnessChanged: _onStrictnessChanged,
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
      case 'Settings':
        return SettingsPage(
          strictnessLevel: _strictnessLevel,
          onStrictnessChanged: _onStrictnessChanged,
          onClearHistory: _onClearHistory,
        );
      case 'About':
        return const AboutPage();
      default:
        return OraclePage(
          balanceController: _balanceController,
          fixedCostsController: _fixedCostsController,
          priceController: _priceController,
          itemNameController: _itemNameController,
          lastMonthSpendController: _lastMonthSpendController,
          availableBudgetController: _availableBudgetController,
          remainingBudgetController: _remainingBudgetController,
          lastMonthSpend: _lastMonthSpend,
          strictnessLevel: _strictnessLevel,
          onNavigateTo: _navigateTo,
          onLastMonthSpendChanged: _onLastMonthSpendChanged,
          onOracleResult: _onOracleResult,
          onStrictnessChanged: _onStrictnessChanged,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Row(
        children: [
          AppSidebar(
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
