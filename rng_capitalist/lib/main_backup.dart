// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/fixed_cost.dart';
import 'models/purchase_history.dart';
import 'models/dice_modifier.dart';
import 'models/sunk_cost.dart';
import 'services/complete_firestore_service.dart';
import 'services/user_auth_service.dart';
import 'screens/auth_screen.dart';
import 'components/oracle_page_dnd.dart';
import 'components/history_page.dart';
import 'components/fixed_costs_page.dart';
import 'components/modifiers_page.dart';
import 'components/sunk_costs_page.dart';
import 'components/schedule_page.dart';
import 'components/spinner_page.dart';
import 'components/about_page_dnd.dart';
import 'components/app_sidebar_dnd.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    try {
      final data = await _firestoreService.loadCompleteData();
      setState(() {
        _balanceController.text = data.lastBalance;
        _lastMonthSpend = data.lastMonthSpend;
        _fixedCosts = data.fixedCosts;
        _purchaseHistory = data.purchaseHistory;
        _sunkCosts = data.sunkCosts;
        if (data.modifiers.isNotEmpty) {
          _modifiers = data.modifiers;
        }
        _currentPage = data.currentPage;
      });
      _calculateTotalFixedCosts();
      _updateLastMonthSpendController();
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
      final data = CompleteAppData(
        lastBalance: _balanceController.text,
        lastMonthSpend: _lastMonthSpend,
        availableBudget: double.tryParse(_availableBudgetController.text) ?? 0.0,
        remainingBudget: double.tryParse(_remainingBudgetController.text) ?? 0.0,
        fixedCosts: _fixedCosts,
        purchaseHistory: _purchaseHistory,
        modifiers: _modifiers,
        sunkCosts: _sunkCosts,
        appSettings: {
          'theme': 'light',
          'notifications': true,
          'autoSync': true,
          'currency': 'USD',
        },
        cooldownTimers: {},
        modifierStates: Map.fromEntries(_modifiers.map((m) => MapEntry(m.id, m.isActive))),
        currentPage: _currentPage,
        scheduleData: {},
        investmentHistory: [],
        spinnerHistory: {},
        deviceName: 'Windows Device',
        platform: 'windows',
        lastSyncTime: DateTime.now(),
      );
      await _firestoreService.saveCompleteData(data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data synced to cloud!'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
      appBar: AppBar(
        title: Text('RNG Capitalist - $_currentPage'),
        backgroundColor: Colors.purple.shade100,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync, color: Colors.purple),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔄 Syncing data to cloud...'),
                  duration: Duration(seconds: 1),
                ),
              );
              await _saveSettings();
            },
            tooltip: 'Sync to Cloud',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.purple),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔄 Loading data from cloud...'),
                  duration: Duration(seconds: 1),
                ),
              );
              await _loadSettings();
            },
            tooltip: 'Load from Cloud',
          ),
        ],
      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Test cloud connection and show sync status
          final status = await _firestoreService.getSyncStatus();
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('☁️ Cloud Sync Status'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Has Data: ${status['hasData'] ? '✅ Yes' : '❌ No'}'),
                    if (status['hasData']) ...[
                      const SizedBox(height: 8),
                      Text('User ID: ${status['userId']?.toString().substring(0, 12)}...'),
                      Text('Device: ${status['deviceName']}'),
                      Text('Platform: ${status['platform']}'),
                      Text('Last Sync: ${status['lastSyncTime']}'),
                      const SizedBox(height: 8),
                      const Text('📊 Data Counts:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('• Fixed Costs: ${status['itemCounts']['fixedCosts']}'),
                      Text('• Purchase History: ${status['itemCounts']['purchaseHistory']}'),
                      Text('• Modifiers: ${status['itemCounts']['modifiers']}'),
                      Text('• Sunk Costs: ${status['itemCounts']['sunkCosts']}'),
                      Text('• Investment History: ${status['itemCounts']['investmentHistory']}'),
                      Text('• Cooldowns: ${status['itemCounts']['cooldowns']}'),
                    ],
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }
        },
        backgroundColor: Colors.purple,
        tooltip: 'View Cloud Sync Status',
        child: const Icon(Icons.cloud_queue, color: Colors.white),
      ),
    );
  }
}