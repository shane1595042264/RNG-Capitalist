// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'firebase_options.dart';
import 'models/fixed_cost.dart';
import 'models/purchase_history.dart';
import 'models/dice_modifier.dart';
import 'models/sunk_cost.dart';
import 'models/smart_expense.dart';
import 'services/complete_firestore_service.dart';
import 'services/budget_alert_service.dart';
import 'components/oracle_page_dnd.dart';
import 'components/history_page.dart';
import 'components/fixed_costs_page.dart';
import 'components/modifiers_page.dart';
import 'components/sunk_costs_page.dart';
import 'components/schedule_page.dart';
import 'components/spinner_page.dart';
import 'components/about_page_dnd.dart';
import 'components/app_sidebar_dnd.dart';
import 'components/receipt_scanner_screen.dart';
import 'components/spending_analytics_dashboard.dart';
import 'components/budget_alerts_widget.dart';
import 'components/social_sharing_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ Warning: Could not load .env file: $e');
    print('AI features may not work without proper API key configuration');
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  // Services
  final CompleteFirestoreService _firestoreService = CompleteFirestoreService();
  
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
  List<SunkCost> _sunkCosts = [];
  List<SmartExpense> _smartExpenses = [];
  double _lastMonthSpend = 0.0;
  String _currentPage = 'Oracle';
  
  // Services for new features
  final BudgetAlertService _budgetAlertService = BudgetAlertService();
  
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
    try {
      final data = await _firestoreService.loadCompleteData();
      if (data != null) {
        setState(() {
          _balanceController.text = data.lastBalance;
          _lastMonthSpend = data.lastMonthSpend;
          _fixedCosts = data.fixedCosts;
          _purchaseHistory = data.purchaseHistory;
          _sunkCosts = data.sunkCosts;
          _smartExpenses = data.smartExpenses;
          if (data.modifiers.isNotEmpty) {
            _modifiers = data.modifiers;
          }
        });
        _calculateTotalFixedCosts();
        _updateLastMonthSpendController();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final currentBalance = double.tryParse(_balanceController.text) ?? 0.0;
      final availableBudget = currentBalance - _lastMonthSpend;
      final totalFixedCosts = _fixedCosts.where((c) => c.isActive).fold(0.0, (sum, cost) => sum + cost.amount);
      final remainingBudget = availableBudget - totalFixedCosts;
      
      final data = CompleteAppData(
        lastBalance: _balanceController.text,
        lastMonthSpend: _lastMonthSpend,
        availableBudget: availableBudget,
        remainingBudget: remainingBudget,
        fixedCosts: _fixedCosts,
        purchaseHistory: _purchaseHistory,
        modifiers: _modifiers,
        sunkCosts: _sunkCosts,
        smartExpenses: _smartExpenses,
        appSettings: {},
        cooldownTimers: {},
        modifierStates: {},
        currentPage: _currentPage,
        scheduleData: {},
        investmentHistory: [],
        spinnerHistory: {},
        deviceName: Platform.isWindows ? 'Windows PC' : 'Unknown',
        platform: Platform.operatingSystem,
        lastSyncTime: DateTime.now(),
      );
      await _firestoreService.saveCompleteData(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  void _onAddSmartExpense(SmartExpense expense) {
    setState(() {
      _smartExpenses.insert(0, expense);
      if (_smartExpenses.length > 500) {
        _smartExpenses.removeLast();
      }
    });
    _saveSettings();
    _budgetAlertService.checkBudgetAlerts(_smartExpenses);
  }

  void _onDeleteSmartExpense(String expenseId) {
    setState(() {
      _smartExpenses.removeWhere((expense) => expense.id == expenseId);
    });
    _saveSettings();
  }

  void _navigateToReceiptScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReceiptScannerScreen(
          onExpenseAdded: _onAddSmartExpense,
        ),
      ),
    );
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

  void _onAddSunkCost(SunkCost cost) {
    setState(() {
      _sunkCosts.add(cost);
    });
    _saveSettings();
  }

  void _onEditSunkCost(SunkCost updatedCost) {
    setState(() {
      final index = _sunkCosts.indexWhere((c) => c.id == updatedCost.id);
      if (index != -1) {
        _sunkCosts[index] = updatedCost;
      }
    });
    _saveSettings();
  }

  void _onDeleteSunkCost(String costId) {
    setState(() {
      _sunkCosts.removeWhere((c) => c.id == costId);
    });
    _saveSettings();
  }

  void _onToggleSunkCost(SunkCost cost, bool isActive) {
    setState(() {
      final index = _sunkCosts.indexOf(cost);
      _sunkCosts[index] = SunkCost(
        id: cost.id,
        name: cost.name,
        amount: cost.amount,
        category: cost.category,
        isActive: isActive,
      );
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
          purchaseHistory: _purchaseHistory,
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
      case 'Sunk Costs':
        return SunkCostsPage(
          sunkCosts: _sunkCosts,
          onAddCost: _onAddSunkCost,
          onEditCost: _onEditSunkCost,
          onDeleteCost: _onDeleteSunkCost,
          onToggleCost: _onToggleSunkCost,
        );
      case 'Schedule':
        return SchedulePage(
          sunkCosts: _sunkCosts,
        );
      case 'Spinner':
        return SpinnerPage(
          sunkCosts: _sunkCosts,
        );
      case 'Receipt Scanner':
        return ReceiptScannerScreen(
          onExpenseAdded: _onAddSmartExpense,
        );
      case 'Budget Analytics':
        return SpendingAnalyticsDashboard(
          expenses: _smartExpenses,
        );
      case 'Smart Budget':
        return _buildSmartBudgetPage();
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
          purchaseHistory: _purchaseHistory,
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

  Widget _buildSmartBudgetPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy, size: 32, color: Colors.purple),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Smart D&D Budget Tracker',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToReceiptScanner,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Budget Alerts
          BudgetAlertsWidget(expenses: _smartExpenses),
          const SizedBox(height: 16),
          
          // Recent Expenses
          _buildRecentExpensesCard(),
          const SizedBox(height: 16),
          
          // Quick Stats
          _buildQuickStatsCard(),
          const SizedBox(height: 16),
          
          // Social Sharing
          SocialSharingWidget(expenses: _smartExpenses),
          const SizedBox(height: 16),
          
          // Achievement Badges
          AchievementBadges(expenses: _smartExpenses),
        ],
      ),
    );
  }

  Widget _buildRecentExpensesCard() {
    final recentExpenses = _smartExpenses.take(10).toList();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.purple),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Recent D&D Expenses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateTo('Budget Analytics'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentExpenses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No expenses tracked yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start by scanning a receipt or adding expenses manually',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentExpenses.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final expense = recentExpenses[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: expense.isDnDExpense ? Colors.purple.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      child: Text(
                        expense.category.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(expense.description),
                    subtitle: Text('${expense.category.name} • ${expense.formattedDate}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          expense.formattedAmount,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (expense.isDnDExpense)
                          const Icon(Icons.casino, size: 16, color: Colors.purple),
                      ],
                    ),
                    onTap: () => _showExpenseDetails(expense),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    final dndExpenses = _smartExpenses.where((e) => e.isDnDExpense).toList();
    final totalDnDSpent = dndExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final thisMonthExpenses = _smartExpenses.where((e) {
      final now = DateTime.now();
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();
    final thisMonthSpent = thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Quick Stats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total D&D Expenses',
                    '\$${totalDnDSpent.toStringAsFixed(2)}',
                    Icons.casino,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'This Month',
                    '\$${thisMonthSpent.toStringAsFixed(2)}',
                    Icons.calendar_month,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Expenses',
                    '${_smartExpenses.length}',
                    Icons.receipt_long,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showExpenseDetails(SmartExpense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${expense.formattedAmount}'),
            Text('Category: ${expense.category.name}'),
            Text('Date: ${expense.formattedDate}'),
            if (expense.notes != null) Text('Notes: ${expense.notes}'),
            if (expense.isDnDExpense)
              const Row(
                children: [
                  Icon(Icons.casino, size: 16, color: Colors.purple),
                  SizedBox(width: 4),
                  Text('D&D Related', style: TextStyle(color: Colors.purple)),
                ],
              ),
            if (expense.receiptImagePath != null)
              const Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text('Receipt Available', style: TextStyle(color: Colors.green)),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _onDeleteSmartExpense(expense.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}