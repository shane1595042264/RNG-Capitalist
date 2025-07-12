// main_integrated_sync.dart - Your full RNG Capitalist app with complete cloud sync (no auth)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'lib/firebase_options.dart';
import 'lib/services/complete_firestore_service.dart';
import 'lib/models/fixed_cost.dart';
import 'lib/models/purchase_history.dart';
import 'lib/models/dice_modifier.dart';
import 'lib/models/sunk_cost.dart';
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
      title: 'RNG Capitalist - D&D Edition (Cloud Sync)',
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
  CompleteAppData? _completeData;
  
  // Cloud sync state
  bool _isSyncing = false;
  String _syncStatus = 'Ready';
  DateTime? _lastSyncTime;

  String get _deviceName {
    if (kIsWeb) return 'Web Browser';
    try {
      return Platform.operatingSystem.toUpperCase();
    } catch (e) {
      return 'Windows PC';
    }
  }

  String get _platform {
    if (kIsWeb) return 'web';
    try {
      return Platform.operatingSystem.toLowerCase();
    } catch (e) {
      return 'windows';
    }
  }
  
  @override
  void initState() {
    super.initState();
    _loadCompleteSettings();
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

  Future<void> _loadCompleteSettings() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Loading from cloud...';
    });

    try {
      final data = await _firestoreService.loadCompleteData(
        deviceName: _deviceName,
        platform: _platform,
      );
      
      setState(() {
        _completeData = data;
        _balanceController.text = data.lastBalance;
        _lastMonthSpend = data.lastMonthSpend;
        _fixedCosts = List.from(data.fixedCosts);
        _purchaseHistory = List.from(data.purchaseHistory);
        _sunkCosts = List.from(data.sunkCosts);
        if (data.modifiers.isNotEmpty) {
          _modifiers = List.from(data.modifiers);
        }
        _lastSyncTime = data.lastSyncTime;
        _syncStatus = 'Loaded from cloud';
      });
      
      _calculateTotalFixedCosts();
      _updateLastMonthSpendController();
      _showCloudMessage('✅ All data loaded from cloud!', isError: false);
    } catch (e) {
      setState(() {
        _syncStatus = 'Error loading';
      });
      _showCloudMessage('❌ Error loading: $e', isError: true);
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _saveCompleteSettings() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Saving to cloud...';
    });

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
        appSettings: _completeData?.appSettings ?? {
          'theme': 'light',
          'notifications': true,
          'autoSync': true,
          'currency': 'USD',
        },
        cooldownTimers: _completeData?.cooldownTimers ?? {},
        modifierStates: _extractModifierStates(),
        currentPage: _currentPage,
        scheduleData: _completeData?.scheduleData ?? {},
        investmentHistory: _completeData?.investmentHistory ?? [],
        spinnerHistory: _completeData?.spinnerHistory ?? {},
        deviceName: _deviceName,
        platform: _platform,
        lastSyncTime: DateTime.now(),
      );
      
      await _firestoreService.saveCompleteData(data);
      
      setState(() {
        _completeData = data;
        _lastSyncTime = data.lastSyncTime;
        _syncStatus = 'Saved to cloud';
      });
      
      _showCloudMessage('✅ All data saved to cloud!', isError: false);
    } catch (e) {
      setState(() {
        _syncStatus = 'Error saving';
      });
      _showCloudMessage('❌ Error saving: $e', isError: true);
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Map<String, bool> _extractModifierStates() {
    final states = <String, bool>{};
    for (final modifier in _modifiers) {
      states[modifier.id] = modifier.isActive;
    }
    return states;
  }

  void _showCloudMessage(String message, {required bool isError}) {
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
            _saveCompleteSettings(); // Auto-save after purchase
          },
          onBalanceChanged: () {
            _updateAvailableBudget();
            _saveCompleteSettings(); // Auto-save when balance changes
          },
        );
      case 'History':
        return HistoryPage(
          purchaseHistory: _purchaseHistory,
          onClearHistory: () {
            setState(() {
              _purchaseHistory.clear();
            });
            _saveCompleteSettings();
          },
          onDeleteItem: (index) {
            setState(() {
              _purchaseHistory.removeAt(index);
            });
            _saveCompleteSettings();
          },
        );
      case 'Fixed Costs':
        return FixedCostsPage(
          fixedCosts: _fixedCosts,
          onAddCost: (cost) {
            setState(() {
              _fixedCosts.add(cost);
              _calculateTotalFixedCosts();
            });
            _saveCompleteSettings();
          },
          onEditCost: (index, cost) {
            setState(() {
              _fixedCosts[index] = cost;
              _calculateTotalFixedCosts();
            });
            _saveCompleteSettings();
          },
          onDeleteCost: (index) {
            setState(() {
              _fixedCosts.removeAt(index);
              _calculateTotalFixedCosts();
            });
            _saveCompleteSettings();
          },
          onToggleCost: (index) {
            setState(() {
              final cost = _fixedCosts[index];
              _fixedCosts[index] = FixedCost(
                id: cost.id,
                name: cost.name,
                amount: cost.amount,
                category: cost.category,
                isActive: !cost.isActive,
              );
              _calculateTotalFixedCosts();
            });
            _saveCompleteSettings();
          },
        );
      case 'Modifiers':
        return ModifiersPage(
          userModifiers: _modifiers,
          onToggleModifier: (modifier) {
            setState(() {
              final index = _modifiers.indexWhere((m) => m.id == modifier.id);
              if (index != -1) {
                _modifiers[index] = modifier.copyWith(isActive: !modifier.isActive);
              }
            });
            _saveCompleteSettings();
          },
          onModifiersChanged: (modifiers) {
            setState(() {
              _modifiers = modifiers;
            });
            _saveCompleteSettings();
          },
        );
      case 'Sunk Costs':
        return SunkCostsPage(
          sunkCosts: _sunkCosts,
          onSunkCostsChanged: (costs) {
            setState(() {
              _sunkCosts = costs;
            });
            _saveCompleteSettings();
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
            _saveCompleteSettings();
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
              _saveCompleteSettings(); // Save page state
            },
          ),
          Expanded(
            child: Column(
              children: [
                // Cloud sync status bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: _syncStatus.contains('Error') 
                      ? Colors.red.shade50 
                      : _syncStatus.contains('cloud') 
                          ? Colors.green.shade50
                          : Colors.blue.shade50,
                  child: Row(
                    children: [
                      if (_isSyncing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          _syncStatus.contains('Error') 
                              ? Icons.cloud_off
                              : Icons.cloud_done,
                          size: 16, 
                          color: _syncStatus.contains('Error') 
                              ? Colors.red 
                              : Colors.green,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🎉 COMPLETE CLOUD SYNC: $_syncStatus',
                          style: TextStyle(
                            fontSize: 12, 
                            color: _syncStatus.contains('Error') 
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_lastSyncTime != null) ...[
                        Text(
                          'Last: ${_lastSyncTime!.toString().substring(11, 16)}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                      ],
                      ElevatedButton.icon(
                        onPressed: _isSyncing ? null : _saveCompleteSettings,
                        icon: const Icon(Icons.cloud_upload, size: 16),
                        label: const Text('Save All'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isSyncing ? null : _loadCompleteSettings,
                        icon: const Icon(Icons.cloud_download, size: 16),
                        label: const Text('Load All'),
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
