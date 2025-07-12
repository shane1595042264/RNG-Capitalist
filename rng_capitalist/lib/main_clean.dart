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
import 'components/about_page.dart';
import 'components/app_sidebar_dnd.dart';
import 'utils/purchase_cooldown.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
        ),
        useMaterial3: true,
      ),
      home: const AuthenticatedHomePage(),
    );
  }
}

// Authentication wrapper for the existing app
class AuthenticatedHomePage extends StatefulWidget {
  const AuthenticatedHomePage({Key? key}) : super(key: key);

  @override
  State<AuthenticatedHomePage> createState() => _AuthenticatedHomePageState();
}

class _AuthenticatedHomePageState extends State<AuthenticatedHomePage> {
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
                Icon(Icons.casino, size: 64, color: Color(0xFF9C27B0)),
                SizedBox(height: 24),
                Text('RNG CAPITALIST', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
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
                      const Icon(Icons.casino, size: 80, color: Color(0xFF9C27B0)),
                      const SizedBox(height: 16),
                      const Text('RNG CAPITALIST', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
                      const Text('D&D Oracle & Budget Manager', style: TextStyle(fontSize: 16, color: Color(0xFF757575))),
                      const SizedBox(height: 32),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            _FeatureRow(icon: Icons.cloud, title: 'Cloud Sync', subtitle: 'Your data syncs across all devices'),
                            SizedBox(height: 12),
                            _FeatureRow(icon: Icons.casino, title: 'D&D Oracle', subtitle: 'Let the dice guide your purchases'),
                            SizedBox(height: 12),
                            _FeatureRow(icon: Icons.account_balance_wallet, title: 'Budget Manager', subtitle: 'Track spending and investments'),
                            SizedBox(height: 12),
                            _FeatureRow(icon: Icons.security, title: 'Secure & Private', subtitle: 'Your own account, your own data'),
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
                      
                      Text('Start your D&D financial adventure!', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // User is authenticated, show the EXISTING HomePage
    return const HomePage();
  }
}

// Helper widget for feature list
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  
  const _FeatureRow({required this.icon, required this.title, required this.subtitle});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9C27B0), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
            ],
          ),
        ),
      ],
    );
  }
}

// HomePage class with authentication integration
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _balanceController = TextEditingController();
  final _lastMonthSpendController = TextEditingController();
  
  String _currentPage = 'Oracle';
  double _lastMonthSpend = 0.0;
  double _totalFixedCosts = 0.0;
  
  List<FixedCost> _fixedCosts = [];
  List<PurchaseHistory> _purchaseHistory = [];
  List<DiceModifier> _modifiers = [];
  List<SunkCost> _sunkCosts = [];
  
  final CompleteFirestoreService _firestoreService = CompleteFirestoreService();
  final UserAuthService _authService = UserAuthService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _lastMonthSpendController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final data = await _firestoreService.loadCompleteAppData();
      if (data != null) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      _lastMonthSpend = double.tryParse(_lastMonthSpendController.text) ?? _lastMonthSpend;
      
      final data = CompleteAppData(
        lastBalance: _balanceController.text,
        lastMonthSpend: _lastMonthSpend,
        fixedCosts: _fixedCosts,
        purchaseHistory: _purchaseHistory,
        modifiers: _modifiers,
        sunkCosts: _sunkCosts,
        currentPage: _currentPage,
      );
      
      await _firestoreService.saveCompleteAppData(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _calculateTotalFixedCosts() {
    _totalFixedCosts = _fixedCosts.fold(0.0, (sum, cost) => sum + cost.amount);
    setState(() {});
  }

  void _showTotalCostsSnackBar() {
    final avgMonthlySpend = _lastMonthSpend;
    final totalMonthlyCommitment = _totalFixedCosts;
    final remainingBudget = avgMonthlySpend - totalMonthlyCommitment;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Total Fixed: \$${_totalFixedCosts.toStringAsFixed(2)} | '
          'Monthly Spend: \$${avgMonthlySpend.toStringAsFixed(2)} | '
          'Available: \$${remainingBudget.toStringAsFixed(2)}',
        ),
        backgroundColor: remainingBudget >= 0 ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _addPurchaseHistory(PurchaseHistory purchase) {
    setState(() {
      _purchaseHistory.add(purchase);
    });
    _saveSettings();
  }

  void _onDeletePurchase(String id) {
    setState(() {
      _purchaseHistory.removeWhere((p) => p.id == id);
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

  void _onDeleteFixedCost(String id) {
    setState(() {
      _fixedCosts.removeWhere((c) => c.id == id);
      _calculateTotalFixedCosts();
    });
    _saveSettings();
  }

  void _onAddModifier(DiceModifier modifier) {
    setState(() {
      _modifiers.add(modifier);
    });
    _saveSettings();
  }

  void _onEditModifier(DiceModifier updatedModifier) {
    setState(() {
      final index = _modifiers.indexWhere((m) => m.id == updatedModifier.id);
      if (index != -1) {
        _modifiers[index] = updatedModifier;
      }
    });
    _saveSettings();
  }

  void _onDeleteModifier(String id) {
    setState(() {
      _modifiers.removeWhere((m) => m.id == id);
    });
    _saveSettings();
  }

  void _onAddSunkCost(SunkCost sunkCost) {
    setState(() {
      _sunkCosts.add(sunkCost);
    });
    _saveSettings();
  }

  void _onEditSunkCost(SunkCost updatedSunkCost) {
    setState(() {
      final index = _sunkCosts.indexWhere((s) => s.id == updatedSunkCost.id);
      if (index != -1) {
        _sunkCosts[index] = updatedSunkCost;
      }
    });
    _saveSettings();
  }

  void _onDeleteSunkCost(String id) {
    setState(() {
      _sunkCosts.removeWhere((s) => s.id == id);
    });
    _saveSettings();
  }

  Widget _buildMainContent() {
    switch (_currentPage) {
      case 'Oracle':
        return OraclePageDnD(
          balanceController: _balanceController,
          totalFixedCosts: _totalFixedCosts,
          lastMonthSpend: _lastMonthSpend,
          onPurchaseAdded: _addPurchaseHistory,
          showTotalCostsSnackBar: _showTotalCostsSnackBar,
          modifiers: _modifiers,
        );
      case 'History':
        return HistoryPage(
          purchaseHistory: _purchaseHistory,
          onDeletePurchase: _onDeletePurchase,
        );
      case 'Fixed Costs':
        return FixedCostsPage(
          fixedCosts: _fixedCosts,
          onAddFixedCost: _onAddFixedCost,
          onEditFixedCost: _onEditFixedCost,
          onDeleteFixedCost: _onDeleteFixedCost,
          totalFixedCosts: _totalFixedCosts,
        );
      case 'Modifiers':
        return ModifiersPage(
          modifiers: _modifiers,
          onAddModifier: _onAddModifier,
          onEditModifier: _onEditModifier,
          onDeleteModifier: _onDeleteModifier,
        );
      case 'Sunk Costs':
        return SunkCostsPage(
          sunkCosts: _sunkCosts,
          onAddSunkCost: _onAddSunkCost,
          onEditSunkCost: _onEditSunkCost,
          onDeleteSunkCost: _onDeleteSunkCost,
        );
      case 'Schedule':
        return SchedulePage(
          onLastMonthSpendChanged: (value) {
            _lastMonthSpend = value;
            _saveSettings();
          },
          initialLastMonthSpend: _lastMonthSpend,
        );
      case 'Spinner':
        return const SpinnerPage();
      case 'About':
        return const AboutPage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.purple),
            tooltip: 'Account Management',
            onSelected: (value) async {
              switch (value) {
                case 'change_password':
                  await _showChangePasswordDialog();
                  break;
                case 'switch_account':
                  await _showSwitchAccountDialog();
                  break;
                case 'delete_account':
                  await _showDeleteAccountDialog();
                  break;
                case 'logout':
                  await _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'change_password',
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Change Password'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'switch_account',
                child: Row(
                  children: [
                    Icon(Icons.switch_account, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Switch Account'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_account',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Account'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          AppSidebarDnD(
            currentPage: _currentPage,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
              _saveSettings();
            },
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
                  ],
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

  // Account management methods
  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Change Password'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setDialogState(() => obscureCurrentPassword = !obscureCurrentPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setDialogState(() => obscureNewPassword = !obscureNewPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setDialogState(() => obscureConfirmPassword = !obscureConfirmPassword),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FilledButton(
                  onPressed: () async {
                    if (newPasswordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New passwords do not match')),
                      );
                      return;
                    }

                    try {
                      await _authService.changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Password changed successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Failed to change password: $e')),
                      );
                    }
                  },
                  child: const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSwitchAccountDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.switch_account, color: Colors.blue),
              SizedBox(width: 8),
              Text('Switch Account'),
            ],
          ),
          content: const Text('You will be logged out and can login with a different account. Continue?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
              child: const Text('Switch Account'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Account'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '⚠️ WARNING ⚠️\n\nThis will permanently delete your account and ALL your data including:\n\n• Purchase history\n• Fixed costs\n• Modifiers\n• Sunk costs\n• Investment history\n\nThis action cannot be undone!',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm with your password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    try {
                      await _authService.deleteAccount(passwordController.text);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account deleted successfully')),
                      );
                      // Restart the app to show login screen
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MyApp()),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Failed to delete account: $e')),
                      );
                    }
                  },
                  child: const Text('DELETE ACCOUNT', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      // Restart the app to show login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyApp()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to logout: $e')),
      );
    }
  }
}
