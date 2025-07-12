// Modified version of your main app with cloud sync ready for authentication
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/firestore_service_no_auth.dart';
import 'lib/models/fixed_cost.dart';
import 'lib/models/purchase_history.dart';
import 'lib/models/dice_modifier.dart';
import 'lib/models/sunk_cost.dart';
import 'lib/components/oracle_page_dnd.dart';
import 'lib/components/history_page.dart';
import 'lib/components/fixed_costs_page.dart';
import 'lib/components/modifiers_page.dart';
import 'lib/components/sunk_costs_page.dart';
import 'lib/components/schedule_page.dart';
import 'lib/components/spinner_page.dart';
import 'lib/components/about_page_dnd.dart';
import 'lib/components/app_sidebar_dnd.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  runApp(const RNGCapitalistCloudApp());
}

class RNGCapitalistCloudApp extends StatelessWidget {
  const RNGCapitalistCloudApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist - Cloud Edition',
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
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  List<FixedCost> _fixedCosts = [];
  List<PurchaseHistory> _purchaseHistory = [];
  List<DiceModifier> _modifiers = [];
  List<SunkCost> _sunkCosts = [];
  String _lastBalance = '0.0';
  double _lastMonthSpend = 0.0;

  final FirestoreServiceNoAuth _firestoreService = FirestoreServiceNoAuth();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _fixedCostsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _balanceController.text = _lastBalance;
    _initializePages();
    _loadData();
  }

  void _initializePages() {
    _pages = [
      OraclePageDnD(
        balanceController: _balanceController,
        priceController: _priceController,
        itemNameController: _itemNameController,
        fixedCostsController: _fixedCostsController,
      ),
      HistoryPage(
        purchaseHistory: _purchaseHistory,
        onDataChanged: _handleDataChanged,
      ),
      FixedCostsPage(
        fixedCosts: _fixedCosts,
        onDataChanged: _handleDataChanged,
      ),
      ModifiersPage(
        modifiers: _modifiers,
        onDataChanged: _handleDataChanged,
      ),
      SunkCostsPage(
        sunkCosts: _sunkCosts,
        onDataChanged: _handleDataChanged,
      ),
      const SchedulePage(),
      const SpinnerPage(),
      const AboutPageDnD(),
    ];
  }

  Future<void> _loadData() async {
    try {
      final data = await _firestoreService.loadUserData();
      if (data != null) {
        setState(() {
          _fixedCosts = data.fixedCosts;
          _purchaseHistory = data.purchaseHistory;
          _modifiers = data.modifiers;
          _sunkCosts = data.sunkCosts;
          _lastBalance = data.lastBalance.toString();
          _lastMonthSpend = data.lastMonthSpend;
          _balanceController.text = _lastBalance;
        });
        _initializePages();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data synced from cloud!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Cloud sync unavailable: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleDataChanged() async {
    // Auto-save to cloud whenever data changes
    final data = AppDataCloudNoAuth(
      lastBalance: double.tryParse(_balanceController.text) ?? 0.0,
      lastMonthSpend: _lastMonthSpend,
      fixedCosts: _fixedCosts,
      purchaseHistory: _purchaseHistory,
      modifiers: _modifiers,
      sunkCosts: _sunkCosts,
    );
    
    try {
      await _firestoreService.saveUserData(data);
      // Show brief success indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💾 Auto-saved to cloud'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Auto-save failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Auto-save failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    
    setState(() {
      _initializePages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RNG Capitalist - Cloud Edition'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync),
            onPressed: _loadData,
            tooltip: 'Sync from Cloud',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _handleDataChanged(),
            tooltip: 'Force Save to Cloud',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Demo Mode'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.cloud),
                    SizedBox(width: 8),
                    Text('Force Sync'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'sync') {
                _loadData();
              } else if (value == 'info') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Demo Mode'),
                    content: const Text(
                      'This is a demo version with cloud sync.\n\n'
                      'All data is shared in demo mode.\n'
                      'Full authentication coming soon!'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: AppSidebarDnD(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}
