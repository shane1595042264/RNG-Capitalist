// lib/main_integrated.dart - Complete integration of authentication with existing app
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
                Text('Checking authentication...'),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
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
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Services
  final CompleteFirestoreService _firestoreService = CompleteFirestoreService();
  final UserAuthService _authService = UserAuthService();
  
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
  
  // Auth-related state
  Map<String, dynamic>? _userProfile;
  String? _syncStatus;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUserProfile();
    _initializeDefaultModifiers();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      // Handle silently
    }
  }
  
  void _initializeDefaultModifiers() {
    // Get all preset modifiers
    final presetModifiers = DiceModifier.getPresetModifiers();
    
    // If no saved modifiers, use presets
    if (_modifiers.isEmpty) {
      setState(() {
        _modifiers = presetModifiers;
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final data = await _firestoreService.loadCompleteData();
      if (data != null) {
        setState(() {
          _fixedCosts = data.fixedCosts;
          _purchaseHistory = data.purchaseHistory;
          _modifiers = data.modifiers;
          _sunkCosts = data.sunkCosts;
          _lastMonthSpend = data.lastMonthSpend;
          _currentPage = data.currentPage;
        });
      }
      setState(() {
        _syncStatus = 'Synced ${DateTime.now().toString().substring(11, 19)}';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Sync failed';
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final data = CompleteAppData(
        lastBalance: _balanceController.text.isEmpty ? '0.0' : _balanceController.text,
        lastMonthSpend: _lastMonthSpend,
        availableBudget: double.tryParse(_availableBudgetController.text) ?? 0.0,
        remainingBudget: double.tryParse(_remainingBudgetController.text) ?? 0.0,
        fixedCosts: _fixedCosts,
        purchaseHistory: _purchaseHistory,
        modifiers: _modifiers,
        sunkCosts: _sunkCosts,
        appSettings: {},
        cooldownTimers: {},
        modifierStates: {},
        currentPage: _currentPage,
        scheduleData: {},
        investmentHistory: [],
        spinnerHistory: {},
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
    }
  }

  // Account Management Functions
  Future<void> _showAccountMenu() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.account_circle, color: Colors.purple),
            const SizedBox(width: 8),
            Text('Account: ${_userProfile?['username'] ?? 'User'}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Username', _userProfile?['username'] ?? 'Unknown'),
            _buildInfoRow('Account Created', _userProfile?['created_at']?.toString().substring(0, 19) ?? 'Unknown'),
            _buildInfoRow('Last Login', _userProfile?['last_login']?.toString().substring(0, 19) ?? 'Unknown'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Change\nPassword'),
                ),
                TextButton.icon(
                  onPressed: _switchAccount,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Switch\nAccount'),
                ),
                TextButton.icon(
                  onPressed: _deleteAccount,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('Delete\nAccount'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    Navigator.of(context).pop(); // Close account dialog
    
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                helperText: 'At least 6 characters',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              
              final result = await _authService.changePassword(
                oldPasswordController.text,
                newPasswordController.text,
              );
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _switchAccount() async {
    Navigator.of(context).pop(); // Close account dialog
    
    final shouldSwitch = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Account'),
        content: const Text('This will log you out and allow you to sign in with a different account. Your current data will remain safely in the cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Switch Account'),
          ),
        ],
      ),
    );

    if (shouldSwitch == true) {
      await _authService.logoutUser();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    Navigator.of(context).pop(); // Close account dialog
    
    final confirmController = TextEditingController();
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will permanently delete your account and ALL your data from the cloud. This action cannot be undone!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Type "DELETE" to confirm:'),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type DELETE here',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (confirmController.text == 'DELETE') {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please type "DELETE" to confirm')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE ACCOUNT'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _firestoreService.deleteUserData();
        await _authService.logoutUser();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    Navigator.of(context).pop(); // Close account dialog
    
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? Your data will remain safely in the cloud.'),
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
            _buildInfoRow('Connection', status['connected'] ? 'Connected' : 'Offline'),
            _buildInfoRow('User ID', status['userId'] ?? 'Not logged in'),
            _buildInfoRow('Username', _userProfile?['username'] ?? 'Unknown'),
            _buildInfoRow('Has Data', status['hasData'] ? 'Yes' : 'No'),
            if (status['lastSync'] != null)
              _buildInfoRow('Last Sync', status['lastSync']),
            if (status['error'] != null)
              _buildInfoRow('Error', status['error']),
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

  Widget _buildInfoRow(String label, String value) {
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
                fontFamily: value.length > 20 ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 'Oracle':
        return OraclePageDND(
          onPageChange: (page) {
            setState(() {
              _currentPage = page;
            });
            _saveSettings();
          },
          onFixedCostAdd: (cost) {
            setState(() {
              _fixedCosts.add(cost);
            });
            _saveSettings();
          },
          onPurchaseAdd: (purchase) {
            setState(() {
              _purchaseHistory.add(purchase);
            });
            _saveSettings();
          },
          onSunkCostAdd: (cost) {
            setState(() {
              _sunkCosts.add(cost);
            });
            _saveSettings();
          },
          fixedCosts: _fixedCosts,
          purchaseHistory: _purchaseHistory,
          sunkCosts: _sunkCosts,
          modifiers: _modifiers,
        );
      case 'History':
        return HistoryPage(
          purchaseHistory: _purchaseHistory,
        );
      case 'Fixed Costs':
        return FixedCostsPage(
          fixedCosts: _fixedCosts,
          onAddCost: (cost) {
            setState(() {
              _fixedCosts.add(cost);
            });
            _saveSettings();
          },
          onEditCost: (index, cost) {
            setState(() {
              _fixedCosts[index] = cost;
            });
            _saveSettings();
          },
          onDeleteCost: (index) {
            setState(() {
              _fixedCosts.removeAt(index);
            });
            _saveSettings();
          },
          onToggleCost: (index) {
            setState(() {
              _fixedCosts[index] = _fixedCosts[index].copyWith(
                isActive: !_fixedCosts[index].isActive,
              );
            });
            _saveSettings();
          },
        );
      case 'Modifiers':
        return ModifiersPage(
          userModifiers: _modifiers,
          onToggleModifier: (index) {
            setState(() {
              _modifiers[index] = _modifiers[index].copyWith(
                isActive: !_modifiers[index].isActive,
              );
            });
            _saveSettings();
          },
          onAddModifier: (modifier) {
            setState(() {
              _modifiers.add(modifier);
            });
            _saveSettings();
          },
          onDeleteModifier: (index) {
            setState(() {
              _modifiers.removeAt(index);
            });
            _saveSettings();
          },
        );
      case 'Sunk Costs':
        return SunkCostsPage(
          sunkCosts: _sunkCosts,
          onAddCost: (cost) {
            setState(() {
              _sunkCosts.add(cost);
            });
            _saveSettings();
          },
          onDeleteCost: (index) {
            setState(() {
              _sunkCosts.removeAt(index);
            });
            _saveSettings();
          },
        );
      case 'Schedule':
        return SchedulePage(
          onUpdateSchedule: () {
            _saveSettings();
          },
        );
      case 'Spinner':
        return SpinnerPage(
          onAddInvestment: () {
            _saveSettings();
          },
        );
      case 'About':
        return const AboutPageDND();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('RNG Capitalist - D&D Edition'),
            if (_userProfile != null) ...[
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '👤 ${_userProfile!['username']}',
                  style: const TextStyle(fontSize: 12, color: Colors.purple),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Account menu button
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _showAccountMenu,
            tooltip: 'Account Management',
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
        onPageChange: (page) {
          setState(() {
            _currentPage = page;
          });
          _saveSettings();
        },
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
}
