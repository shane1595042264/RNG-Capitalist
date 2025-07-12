// main_no_auth.dart - Version without authentication for testing cloud sync
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/models/fixed_cost.dart';
import 'lib/models/purchase_history.dart';
import 'lib/models/dice_modifier.dart';
import 'lib/models/sunk_cost.dart';
import 'lib/services/firestore_service_no_auth.dart';
import 'lib/components/history_page.dart';
import 'lib/components/fixed_costs_page.dart';
import 'lib/components/modifiers_page.dart';
import 'lib/components/sunk_costs_page.dart';
import 'lib/components/schedule_page.dart';
import 'lib/components/spinner_page.dart';

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
      title: 'RNG Capitalist - D&D Edition (No Auth Demo)',
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
  // Services (using no-auth version)
  final FirestoreServiceNoAuth _firestoreService = FirestoreServiceNoAuth();
  
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
  final List<PurchaseHistory> _purchaseHistory = [];
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
      final data = await _firestoreService.loadTestData();
      setState(() {
        _balanceController.text = data['balance']?.toString() ?? '100.0';
        _lastMonthSpend = (data['lastMonthSpend'] as num?)?.toDouble() ?? 0.0;
        // Note: For this demo, we're only loading/saving basic data
        // Full integration would include all the lists
      });
      _updateLastMonthSpendController();
      _showCloudSyncStatus('Data loaded from cloud!');
    } catch (e) {
      if (mounted) {
        _showCloudSyncStatus('Error loading cloud data: $e', isError: true);
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final data = {
        'balance': double.tryParse(_balanceController.text) ?? 0.0,
        'lastMonthSpend': _lastMonthSpend,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _firestoreService.saveTestData(data);
      _showCloudSyncStatus('Data saved to cloud!');
    } catch (e) {
      if (mounted) {
        _showCloudSyncStatus('Error saving to cloud: $e', isError: true);
      }
    }
  }
  
  void _showCloudSyncStatus(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.cloud_off : Icons.cloud_done,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
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
    double totalFixedCosts = _getTotalFixedCosts();
    double availableBudget = double.tryParse(_availableBudgetController.text) ?? 0.0;
    double remainingBudget = availableBudget - totalFixedCosts;
    _remainingBudgetController.text = remainingBudget.toStringAsFixed(2);
  }
  
  double _getTotalFixedCosts() {
    return _fixedCosts.fold(0.0, (sum, cost) => sum + cost.amount);
  }
  
  void _calculateTotalFixedCosts() {
    double total = _getTotalFixedCosts();
    _fixedCostsController.text = total.toStringAsFixed(2);
    _updateRemainingBudget();
  }

  Widget _getCurrentPage() {
    switch (_currentPage) {
      case 'Oracle':
        return OraclePageDnd(
          balanceController: _balanceController,
          priceController: _priceController,
          itemNameController: _itemNameController,
          availableBudgetController: _availableBudgetController,
          remainingBudgetController: _remainingBudgetController,
          fixedCosts: _fixedCosts,
          modifiers: _modifiers,
          onPurchase: (history) {
            setState(() {
              _purchaseHistory.add(history);
              _updateAvailableBudget();
            });
            _saveSettings(); // Auto-save after purchase
          },
          onBalanceChanged: () {
            _updateAvailableBudget();
            _saveSettings(); // Auto-save when balance changes
          },
        );
      case 'History':
        return HistoryPage(
          purchaseHistory: _purchaseHistory,
          onClearHistory: () {
            setState(() {
              _purchaseHistory.clear();
            });
            _saveSettings();
          },
          onDeleteItem: (index) {
            setState(() {
              _purchaseHistory.removeAt(index);
            });
            _saveSettings();
          },
        );
      case 'Fixed Costs':
        return FixedCostsPage(
          fixedCosts: _fixedCosts,
          onFixedCostsChanged: (costs) {
            setState(() {
              _fixedCosts = costs;
              _calculateTotalFixedCosts();
            });
            _saveSettings();
          },
        );
      case 'Modifiers':
        return ModifiersPage(
          modifiers: _modifiers,
          onModifiersChanged: (modifiers) {
            setState(() {
              _modifiers = modifiers;
            });
            _saveSettings();
          },
        );
      case 'Sunk Costs':
        return SunkCostsPage(
          sunkCosts: _sunkCosts,
          onSunkCostsChanged: (costs) {
            setState(() {
              _sunkCosts = costs;
            });
            _saveSettings();
          },
        );
      case 'Schedule':
        return SchedulePage(
          lastMonthSpendController: _lastMonthSpendController,
          onLastMonthSpendChanged: (value) {
            setState(() {
              _lastMonthSpend = value;
              _updateLastMonthSpendController();
            });
            _saveSettings();
          },
        );
      case 'Spinner':
        return SpinnerPage(
          fixedCosts: _fixedCosts,
          sunkCosts: _sunkCosts,
        );
      case 'About':
        return const AboutPageDnd();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebarDnd(
            currentPage: _currentPage,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                // Cloud sync status bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue.shade50,
                  child: Row(
                    children: [
                      const Icon(Icons.cloud, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Cloud Sync Active (No Auth Demo)',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.cloud_upload, size: 16),
                        label: const Text('Save to Cloud'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _loadSettings,
                        icon: const Icon(Icons.cloud_download, size: 16),
                        label: const Text('Load from Cloud'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _getCurrentPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
