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
      home: const AuthWrapper(),
    );
  }
}

// Authentication wrapper - decides whether to show auth or main app
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final UserAuthService _authService = UserAuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Try auto-login first
      final isLoggedIn = await _authService.autoLogin();
      setState(() {
        _isAuthenticated = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAuthScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.casino,
                  size: 64,
                  color: Colors.purple,
                ),
                SizedBox(height: 24),
                Text(
                  'RNG CAPITALIST',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 16),
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      // Show welcome screen with login option
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Card(
                elevation: 8,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.casino,
                        size: 80,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'RNG CAPITALIST',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const Text(
                        'D&D Oracle & Budget Manager',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Feature highlights
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureItem(Icons.cloud, 'Cloud Sync', 'Your data syncs across all devices'),
                            const SizedBox(height: 12),
                            _buildFeatureItem(Icons.casino, 'D&D Oracle', 'Let the dice guide your purchases'),
                            const SizedBox(height: 12),
                            _buildFeatureItem(Icons.account_balance_wallet, 'Budget Manager', 'Track spending and investments'),
                            const SizedBox(height: 12),
                            _buildFeatureItem(Icons.security, 'Secure & Private', 'Your own account, your own data'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _showAuthScreen,
                          icon: const Icon(Icons.login),
                          label: const Text('LOGIN / CREATE ACCOUNT'),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Start your D&D financial adventure!',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // User is authenticated, show main app
    return const HomePage();
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Main app HomePage (extracted from original)
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CompleteFirestoreService _firestoreService = CompleteFirestoreService();
  final UserAuthService _authService = UserAuthService();
  
  String _currentPage = 'oracle';
  String _lastBalance = '0.0';
  double _lastMonthSpend = 0.0;
  double _availableBudget = 0.0;
  double _remainingBudget = 0.0;
  List<FixedCost> _fixedCosts = [];
  List<PurchaseHistory> _purchaseHistory = [];
  List<DiceModifier> _modifiers = [];
  List<SunkCost> _sunkCosts = [];
  Map<String, dynamic> _appSettings = {};
  Map<String, DateTime> _cooldownTimers = {};
  Map<String, bool> _modifierStates = {};
  Map<String, dynamic> _scheduleData = {};
  List<Map<String, dynamic>> _investmentHistory = [];
  Map<String, dynamic> _spinnerHistory = {};
  
  bool _isLoading = true;
  String? _syncStatus;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _firestoreService.loadCompleteData();
      if (data != null) {
        setState(() {
          _lastBalance = data.lastBalance;
          _lastMonthSpend = data.lastMonthSpend;
          _availableBudget = data.availableBudget;
          _remainingBudget = data.remainingBudget;
          _fixedCosts = data.fixedCosts;
          _purchaseHistory = data.purchaseHistory;
          _modifiers = data.modifiers;
          _sunkCosts = data.sunkCosts;
          _appSettings = data.appSettings;
          _cooldownTimers = data.cooldownTimers;
          _modifierStates = data.modifierStates;
          _currentPage = data.currentPage;
          _scheduleData = data.scheduleData;
          _investmentHistory = data.investmentHistory;
          _spinnerHistory = data.spinnerHistory;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final data = CompleteAppData(
        lastBalance: _lastBalance,
        lastMonthSpend: _lastMonthSpend,
        availableBudget: _availableBudget,
        remainingBudget: _remainingBudget,
        fixedCosts: _fixedCosts,
        purchaseHistory: _purchaseHistory,
        modifiers: _modifiers,
        sunkCosts: _sunkCosts,
        appSettings: _appSettings,
        cooldownTimers: _cooldownTimers,
        modifierStates: _modifierStates,
        currentPage: _currentPage,
        scheduleData: _scheduleData,
        investmentHistory: _investmentHistory,
        spinnerHistory: _spinnerHistory,
        deviceName: 'Windows Device',
        platform: 'windows',
        lastSyncTime: DateTime.now(),
      );
      
      await _firestoreService.saveCompleteData(data);
      setState(() {
        _syncStatus = 'Synced ${DateTime.now().toString().substring(11, 19)}';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Sync failed';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync error: $e')),
        );
      }
    }
  }

  void _updateCurrentPage(String page) {
    setState(() {
      _currentPage = page;
    });
    _saveSettings();
  }

  void _updateBalance(String balance) {
    setState(() {
      _lastBalance = balance;
    });
    _saveSettings();
  }

  void _updateBudgets(double available, double remaining, double monthSpend) {
    setState(() {
      _availableBudget = available;
      _remainingBudget = remaining;
      _lastMonthSpend = monthSpend;
    });
    _saveSettings();
  }

  void _addFixedCost(FixedCost cost) {
    setState(() {
      _fixedCosts.add(cost);
    });
    _saveSettings();
  }

  void _removeFixedCost(int index) {
    setState(() {
      _fixedCosts.removeAt(index);
    });
    _saveSettings();
  }

  void _addPurchaseHistory(PurchaseHistory purchase) {
    setState(() {
      _purchaseHistory.add(purchase);
    });
    _saveSettings();
  }

  void _updateModifiers(List<DiceModifier> modifiers) {
    setState(() {
      _modifiers = modifiers;
    });
    _saveSettings();
  }

  void _updateModifierStates(Map<String, bool> states) {
    setState(() {
      _modifierStates = states;
    });
    _saveSettings();
  }

  void _addSunkCost(SunkCost cost) {
    setState(() {
      _sunkCosts.add(cost);
    });
    _saveSettings();
  }

  void _removeSunkCost(int index) {
    setState(() {
      _sunkCosts.removeAt(index);
    });
    _saveSettings();
  }

  void _updateScheduleData(Map<String, dynamic> data) {
    setState(() {
      _scheduleData = data;
    });
    _saveSettings();
  }

  void _addInvestmentHistory(Map<String, dynamic> investment) {
    setState(() {
      _investmentHistory.add(investment);
    });
    _saveSettings();
  }

  void _updateSpinnerHistory(Map<String, dynamic> history) {
    setState(() {
      _spinnerHistory = history;
    });
    _saveSettings();
  }

  void _setCooldown(String key, DateTime time) {
    setState(() {
      _cooldownTimers[key] = time;
    });
    _saveSettings();
  }

  DateTime? _getCooldown(String key) {
    return _cooldownTimers[key];
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? Your data will remain in the cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.logoutUser();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildCurrentPage() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_currentPage) {
      case 'oracle':
        return OraclePageDND(
          lastBalance: _lastBalance,
          lastMonthSpend: _lastMonthSpend,
          availableBudget: _availableBudget,
          remainingBudget: _remainingBudget,
          modifiers: _modifiers,
          modifierStates: _modifierStates,
          onBalanceUpdate: _updateBalance,
          onBudgetUpdate: _updateBudgets,
          onPurchaseAdd: _addPurchaseHistory,
          onModifierStatesUpdate: _updateModifierStates,
          onSetCooldown: _setCooldown,
          onGetCooldown: _getCooldown,
        );
      case 'history':
        return HistoryPage(
          purchaseHistory: _purchaseHistory,
          onHistoryUpdate: (history) {
            setState(() {
              _purchaseHistory = history;
            });
            _saveSettings();
          },
        );
      case 'fixed_costs':
        return FixedCostsPage(
          fixedCosts: _fixedCosts,
          onAddCost: _addFixedCost,
          onRemoveCost: _removeFixedCost,
        );
      case 'modifiers':
        return ModifiersPage(
          modifiers: _modifiers,
          onModifiersUpdate: _updateModifiers,
        );
      case 'sunk_costs':
        return SunkCostsPage(
          sunkCosts: _sunkCosts,
          onAddCost: _addSunkCost,
          onRemoveCost: _removeSunkCost,
        );
      case 'schedule':
        return SchedulePage(
          scheduleData: _scheduleData,
          onScheduleUpdate: _updateScheduleData,
        );
      case 'spinner':
        return SpinnerPage(
          spinnerHistory: _spinnerHistory,
          onSpinnerUpdate: _updateSpinnerHistory,
          onInvestmentAdd: _addInvestmentHistory,
        );
      case 'about':
        return const AboutPageDND();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Future<void> _showSyncStatusDialog() async {
    final status = await _firestoreService.getSyncStatus();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              status['connected'] ? Icons.cloud_done : Icons.cloud_off,
              color: status['connected'] ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Cloud Sync Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Connection', status['connected'] ? 'Connected' : 'Offline'),
            _buildStatusRow('User ID', status['userId'] ?? 'Not logged in'),
            _buildStatusRow('Has Data', status['hasData'] ? 'Yes' : 'No'),
            _buildStatusRow('Username', _userProfile?['username'] ?? 'Unknown'),
            if (status['lastSync'] != null)
              _buildStatusRow('Last Sync', status['lastSync']),
            if (status['error'] != null)
              _buildStatusRow('Error', status['error'], isError: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (status['connected'])
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveSettings();
              },
              child: const Text('Sync Now'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : null,
                fontFamily: value.length > 20 ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RNG Capitalist - D&D Edition'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // User profile button
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('User Profile'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusRow('Username', _userProfile?['username'] ?? 'Loading...'),
                      _buildStatusRow('Account Created', _userProfile?['created_at']?.toString() ?? 'Unknown'),
                      _buildStatusRow('Last Login', _userProfile?['last_login']?.toString() ?? 'Unknown'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Sync status button
          IconButton(
            icon: Icon(
              _syncStatus != null && _syncStatus!.startsWith('Synced') 
                  ? Icons.cloud_done 
                  : Icons.cloud_queue,
              color: _syncStatus != null && _syncStatus!.startsWith('Synced') 
                  ? Colors.green 
                  : Colors.orange,
            ),
            onPressed: _showSyncStatusDialog,
            tooltip: _syncStatus ?? 'Cloud sync status',
          ),
          // Manual sync button
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _saveSettings,
            tooltip: 'Sync now',
          ),
        ],
      ),
      drawer: AppSidebarDND(
        currentPage: _currentPage,
        onPageChange: _updateCurrentPage,
      ),
      body: _buildCurrentPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSyncStatusDialog,
        backgroundColor: Colors.purple,
        tooltip: 'View Cloud Sync Status',
        child: Icon(
          _syncStatus != null && _syncStatus!.startsWith('Synced') 
              ? Icons.cloud_done 
              : Icons.cloud_queue,
          color: Colors.white,
        ),
      ),
    );
  }
}
