// Temporary version of main.dart without authentication
// This allows us to test cloud sync while we work around Windows Firebase Auth issues

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/fixed_cost.dart';
import 'models/purchase_history.dart';
import 'models/dice_modifier.dart';
import 'models/sunk_cost.dart';
import 'services/firestore_service_no_auth.dart';
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
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  runApp(const RNGCapitalistApp());
}

class RNGCapitalistApp extends StatelessWidget {
  const RNGCapitalistApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist - Cloud Sync Demo',
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
  double _lastBalance = 0.0;
  double _lastMonthSpend = 0.0;

  final FirestoreServiceNoAuth _firestoreService = FirestoreServiceNoAuth();

  @override
  void initState() {
    super.initState();
    _initializePages();
    _loadData();
  }

  void _initializePages() {
    _pages = [
      OraclePageDnD(
        fixedCosts: _fixedCosts,
        purchaseHistory: _purchaseHistory,
        modifiers: _modifiers,
        sunkCosts: _sunkCosts,
        lastBalance: _lastBalance,
        lastMonthSpend: _lastMonthSpend,
        onDataChanged: _handleDataChanged,
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
          _lastBalance = data.lastBalance;
          _lastMonthSpend = data.lastMonthSpend;
        });
        _initializePages();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data loaded from cloud!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to load cloud data: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleDataChanged() async {
    // Save to cloud whenever data changes
    final data = AppDataCloudNoAuth(
      lastBalance: _lastBalance,
      lastMonthSpend: _lastMonthSpend,
      fixedCosts: _fixedCosts,
      purchaseHistory: _purchaseHistory,
      modifiers: _modifiers,
      sunkCosts: _sunkCosts,
    );
    
    try {
      await _firestoreService.saveUserData(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💾 Data synced to cloud!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to sync: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      _initializePages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RNG Capitalist - Cloud Sync Demo'),
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
            tooltip: 'Save to Cloud',
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
