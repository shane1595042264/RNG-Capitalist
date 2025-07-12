// main_complete_sync.dart - FULL APP DATA SYNC - Everything synced across devices!
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RNGCapitalistCompleteApp());
}

class RNGCapitalistCompleteApp extends StatelessWidget {
  const RNGCapitalistCompleteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist - Complete Cloud Sync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CompleteSyncHomePage(),
    );
  }
}

class CompleteSyncHomePage extends StatefulWidget {
  const CompleteSyncHomePage({Key? key}) : super(key: key);

  @override
  State<CompleteSyncHomePage> createState() => _CompleteSyncHomePageState();
}

class _CompleteSyncHomePageState extends State<CompleteSyncHomePage> {
  final CompleteFirestoreService _firestore = CompleteFirestoreService();
  
  // Controllers for form inputs
  final _balanceController = TextEditingController();
  final _lastMonthSpendController = TextEditingController();
  final _deviceNameController = TextEditingController();
  final _newFixedCostNameController = TextEditingController();
  final _newFixedCostAmountController = TextEditingController();
  final _newPurchaseNameController = TextEditingController();
  final _newPurchasePriceController = TextEditingController();
  
  // App state
  CompleteAppData? _appData;
  String _syncStatus = 'Ready to sync';
  bool _isLoading = false;
  String _currentTab = 'Overview';
  
  // Local data (mirrors cloud data)
  List<FixedCost> _fixedCosts = [];
  List<PurchaseHistory> _purchaseHistory = [];
  List<DiceModifier> _modifiers = [];
  List<SunkCost> _sunkCosts = [];
  Map<String, DateTime> _cooldownTimers = {};
  Map<String, bool> _modifierStates = {};
  List<Map<String, dynamic>> _investmentHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  String get _deviceName {
    if (kIsWeb) return 'Web Browser';
    try {
      return Platform.operatingSystem.toUpperCase();
    } catch (e) {
      return 'Unknown Device';
    }
  }

  String get _platform {
    if (kIsWeb) return 'web';
    try {
      return Platform.operatingSystem.toLowerCase();
    } catch (e) {
      return 'unknown';
    }
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
      _syncStatus = 'Initializing app...';
    });

    try {
      _deviceNameController.text = _deviceName;
      await _loadCompleteDataFromCloud();
    } catch (e) {
      _showMessage('Error initializing app: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCompleteDataFromCloud() async {
    setState(() {
      _isLoading = true;
      _syncStatus = 'Loading ALL data from cloud...';
    });

    try {
      final data = await _firestore.loadCompleteData(
        deviceName: _deviceNameController.text.trim(),
        platform: _platform,
      );

      setState(() {
        _appData = data;
        
        // Update controllers
        _balanceController.text = data.lastBalance;
        _lastMonthSpendController.text = data.lastMonthSpend.toString();
        _deviceNameController.text = data.deviceName;
        
        // Update local data
        _fixedCosts = List.from(data.fixedCosts);
        _purchaseHistory = List.from(data.purchaseHistory);
        _modifiers = List.from(data.modifiers);
        _sunkCosts = List.from(data.sunkCosts);
        _cooldownTimers = Map.from(data.cooldownTimers);
        _modifierStates = Map.from(data.modifierStates);
        _investmentHistory = List.from(data.investmentHistory);
        
        _syncStatus = '✅ ALL data loaded from cloud successfully!';
      });

      _showMessage('Complete data loaded from cloud!', isError: false);
    } catch (e) {
      setState(() {
        _syncStatus = '❌ Error loading data: $e';
      });
      _showMessage('Error loading data: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCompleteDataToCloud() async {
    setState(() {
      _isLoading = true;
      _syncStatus = 'Saving ALL data to cloud...';
    });

    try {
      final data = CompleteAppData(
        lastBalance: _balanceController.text,
        lastMonthSpend: double.tryParse(_lastMonthSpendController.text) ?? 0.0,
        availableBudget: double.tryParse(_balanceController.text) ?? 100.0,
        remainingBudget: (double.tryParse(_balanceController.text) ?? 100.0) - 
                        (double.tryParse(_lastMonthSpendController.text) ?? 0.0),
        fixedCosts: _fixedCosts,
        purchaseHistory: _purchaseHistory,
        modifiers: _modifiers,
        sunkCosts: _sunkCosts,
        appSettings: _appData?.appSettings ?? {
          'theme': 'light',
          'notifications': true,
          'autoSync': true,
          'currency': 'USD',
        },
        cooldownTimers: _cooldownTimers,
        modifierStates: _modifierStates,
        currentPage: _currentTab,
        scheduleData: _appData?.scheduleData ?? {},
        investmentHistory: _investmentHistory,
        spinnerHistory: _appData?.spinnerHistory ?? {},
        deviceName: _deviceNameController.text.trim(),
        platform: _platform,
        lastSyncTime: DateTime.now(),
      );

      await _firestore.saveCompleteData(data);
      
      setState(() {
        _appData = data;
        _syncStatus = '✅ ALL data saved to cloud successfully!';
      });

      _showMessage('Complete data saved to cloud!', isError: false);
    } catch (e) {
      setState(() {
        _syncStatus = '❌ Error saving data: $e';
      });
      _showMessage('Error saving data: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addFixedCost() {
    if (_newFixedCostNameController.text.trim().isEmpty ||
        _newFixedCostAmountController.text.trim().isEmpty) return;

    final newCost = FixedCost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _newFixedCostNameController.text.trim(),
      amount: double.tryParse(_newFixedCostAmountController.text) ?? 0.0,
      category: 'Manual',
      isActive: true,
    );

    setState(() {
      _fixedCosts.add(newCost);
    });

    _newFixedCostNameController.clear();
    _newFixedCostAmountController.clear();
    _saveCompleteDataToCloud();
  }

  void _addPurchaseHistory() {
    if (_newPurchaseNameController.text.trim().isEmpty ||
        _newPurchasePriceController.text.trim().isEmpty) return;

    final newPurchase = PurchaseHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: _newPurchaseNameController.text.trim(),
      price: double.tryParse(_newPurchasePriceController.text) ?? 0.0,
      date: DateTime.now(),
      wasPurchased: true,
      threshold: 50.0,
      rollValue: 75.0,
      availableBudget: double.tryParse(_balanceController.text) ?? 100.0,
    );

    setState(() {
      _purchaseHistory.add(newPurchase);
    });

    _newPurchaseNameController.clear();
    _newPurchasePriceController.clear();
    _saveCompleteDataToCloud();
  }

  void _toggleModifier(int index) {
    setState(() {
      final modifier = _modifiers[index];
      _modifiers[index] = modifier.copyWith(isActive: !modifier.isActive);
      _modifierStates[modifier.id] = !modifier.isActive;
    });
    _saveCompleteDataToCloud();
  }

  void _addInvestmentEntry() {
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'manual_entry',
      'amount': double.tryParse(_balanceController.text) ?? 100.0,
      'description': 'Balance update from ${_deviceNameController.text}',
      'date': DateTime.now().toIso8601String(),
      'device': _deviceNameController.text,
    };

    setState(() {
      _investmentHistory.add(entry);
    });
    _saveCompleteDataToCloud();
  }

  void _showMessage(String message, {required bool isError}) {
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sync status card
          Card(
            color: _syncStatus.contains('✅') 
                ? Colors.green.shade50 
                : _syncStatus.contains('❌') 
                    ? Colors.red.shade50 
                    : Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Icon(
                      _syncStatus.contains('✅') 
                          ? Icons.cloud_done 
                          : _syncStatus.contains('❌') 
                              ? Icons.cloud_off 
                              : Icons.cloud,
                      size: 48,
                      color: _syncStatus.contains('✅') 
                          ? Colors.green 
                          : _syncStatus.contains('❌') 
                              ? Colors.red 
                              : Colors.blue,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _syncStatus,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Core data
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Core Financial Data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _balanceController,
                    decoration: const InputDecoration(
                      labelText: 'Current Balance',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lastMonthSpendController,
                    decoration: const InputDecoration(
                      labelText: 'Last Month Spend',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _deviceNameController,
                    decoration: const InputDecoration(
                      labelText: 'Device Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveCompleteDataToCloud,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Save ALL to Cloud'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadCompleteDataFromCloud,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Load ALL from Cloud'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data summary
          if (_appData != null)
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Data Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('💰 Balance: \$${_appData!.lastBalance}'),
                    Text('📊 Fixed Costs: ${_fixedCosts.length} items'),
                    Text('🛒 Purchase History: ${_purchaseHistory.length} items'),
                    Text('🎲 Modifiers: ${_modifiers.length} items (${_modifiers.where((m) => m.isActive).length} active)'),
                    Text('💸 Sunk Costs: ${_sunkCosts.length} items'),
                    Text('⏰ Active Cooldowns: ${_cooldownTimers.length} items'),
                    Text('📈 Investment History: ${_investmentHistory.length} entries'),
                    Text('🖥️ Device: ${_appData!.deviceName} (${_appData!.platform})'),
                    Text('🕒 Last Sync: ${_appData!.lastSyncTime}'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFixedCostsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Fixed Cost',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newFixedCostNameController,
                    decoration: const InputDecoration(
                      labelText: 'Cost Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newFixedCostAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addFixedCost,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Cost'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._fixedCosts.map((cost) => Card(
            child: ListTile(
              title: Text(cost.name),
              subtitle: Text('\$${cost.amount.toStringAsFixed(2)}'),
              trailing: cost.isActive 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.red),
              onTap: () {
                setState(() {
                  final index = _fixedCosts.indexOf(cost);
                  _fixedCosts[index] = FixedCost(
                    id: cost.id,
                    name: cost.name,
                    amount: cost.amount,
                    category: cost.category,
                    isActive: !cost.isActive,
                  );
                });
                _saveCompleteDataToCloud();
              },
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Purchase',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPurchaseNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPurchasePriceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addPurchaseHistory,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add Purchase'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._purchaseHistory.map((purchase) => Card(
            child: ListTile(
              title: Text(purchase.itemName),
              subtitle: Text(
                '\$${purchase.price.toStringAsFixed(2)} - ${purchase.date.toString().substring(0, 16)}\n'
                'Roll: ${purchase.rollValue.toStringAsFixed(1)} vs Threshold: ${purchase.threshold.toStringAsFixed(1)}'
              ),
              trailing: purchase.wasPurchased 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.red),
              isThreeLine: true,
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildModifiersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dice Modifiers',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          ..._modifiers.asMap().entries.map((entry) {
            final index = entry.key;
            final modifier = entry.value;
            return Card(
              child: ListTile(
                leading: Icon(modifier.icon),
                title: Text(modifier.name),
                subtitle: Text(
                  '${modifier.description}\n'
                  'Value: ${modifier.value > 0 ? '+' : ''}${modifier.value}'
                ),
                trailing: Switch(
                  value: modifier.isActive,
                  onChanged: modifier.isUnlocked ? (value) => _toggleModifier(index) : null,
                ),
                isThreeLine: true,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInvestmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Investment History',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addInvestmentEntry,
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Add Current Balance as Investment Entry'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._investmentHistory.map((entry) => Card(
            child: ListTile(
              title: Text(entry['description'] ?? 'Investment Entry'),
              subtitle: Text(
                '\$${(entry['amount'] ?? 0.0).toStringAsFixed(2)}\n'
                '${entry['date'] ?? 'Unknown date'}\n'
                'From: ${entry['device'] ?? 'Unknown device'}'
              ),
              leading: const Icon(Icons.trending_up, color: Colors.green),
              isThreeLine: true,
            ),
          )).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RNG Capitalist - Complete Sync'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _isLoading ? null : _loadCompleteDataFromCloud,
            tooltip: 'Sync All Data',
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Fixed Costs', icon: Icon(Icons.account_balance)),
            Tab(text: 'Purchases', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Modifiers', icon: Icon(Icons.tune)),
            Tab(text: 'Investments', icon: Icon(Icons.trending_up)),
          ],
          onTap: (index) {
            final tabs = ['Overview', 'Fixed Costs', 'Purchases', 'Modifiers', 'Investments'];
            setState(() {
              _currentTab = tabs[index];
            });
          },
        ),
      ),
      body: DefaultTabController(
        length: 5,
        child: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildFixedCostsTab(),
            _buildPurchaseHistoryTab(),
            _buildModifiersTab(),
            _buildInvestmentTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.purple.shade50,
        child: Row(
          children: [
            const Icon(Icons.cloud, color: Colors.purple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🎉 EVERYTHING SYNCS: Balance, Fixed Costs, Purchases, Modifiers, History, Cooldowns, Settings & More!',
                style: TextStyle(
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _lastMonthSpendController.dispose();
    _deviceNameController.dispose();
    _newFixedCostNameController.dispose();
    _newFixedCostAmountController.dispose();
    _newPurchaseNameController.dispose();
    _newPurchasePriceController.dispose();
    super.dispose();
  }
}
