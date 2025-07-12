// lib/main_auth_demo.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/user_auth_service.dart';
import 'services/complete_firestore_service.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AuthDemoApp());
}

class AuthDemoApp extends StatelessWidget {
  const AuthDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist - Authentication Demo',
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

    return const AuthenticatedHomePage();
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

class AuthenticatedHomePage extends StatefulWidget {
  const AuthenticatedHomePage({Key? key}) : super(key: key);

  @override
  State<AuthenticatedHomePage> createState() => _AuthenticatedHomePageState();
}

class _AuthenticatedHomePageState extends State<AuthenticatedHomePage> {
  final UserAuthService _authService = UserAuthService();
  final CompleteFirestoreService _firestoreService = CompleteFirestoreService();
  
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _syncStatus;
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await _authService.getUserProfile();
      final status = await _firestoreService.getSyncStatus();
      final userId = await _authService.getCurrentUserId();
      
      setState(() {
        _userProfile = profile;
        _syncStatus = status;
        _currentUserId = userId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
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

  Future<void> _testCloudSync() async {
    try {
      // Test saving some data
      final testData = CompleteAppData.createDefault(
        deviceName: 'Demo Device',
        platform: 'windows',
      );
      
      await _firestoreService.saveCompleteData(testData);
      
      // Test loading data
      final loadedData = await _firestoreService.loadCompleteData();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Cloud Sync Test'),
            content: Text(
              'Data saved and loaded successfully!\n\n'
              'User ID: $_currentUserId\n'
              'Device: ${loadedData?.deviceName}\n'
              'Platform: ${loadedData?.platform}\n'
              'Last Sync: ${loadedData?.lastSyncTime}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Great!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Sync Error'),
            content: Text('Error: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('RNG Capitalist - Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Welcome, ${_userProfile?['username'] ?? 'User'}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('You are successfully logged in with your custom account.'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // User information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Username', _userProfile?['username'] ?? 'Unknown'),
                    _buildInfoRow('User ID', _currentUserId ?? 'Unknown'),
                    _buildInfoRow('Account Created', _userProfile?['created_at']?.toString().substring(0, 19) ?? 'Unknown'),
                    _buildInfoRow('Last Login', _userProfile?['last_login']?.toString().substring(0, 19) ?? 'Unknown'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Cloud sync status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _syncStatus?['connected'] == true ? Icons.cloud_done : Icons.cloud_off,
                          color: _syncStatus?['connected'] == true ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cloud Sync Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Connection', _syncStatus?['connected'] == true ? 'Connected' : 'Offline'),
                    _buildInfoRow('Has Data', _syncStatus?['hasData'] == true ? 'Yes' : 'No'),
                    if (_syncStatus?['lastSync'] != null)
                      _buildInfoRow('Last Sync', _syncStatus!['lastSync']),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test button
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _testCloudSync,
                      icon: const Icon(Icons.cloud_sync),
                      label: const Text('Test Cloud Sync'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This demo shows the custom authentication system working.\n'
                    'Users can create accounts, login across devices, and have their own private cloud data storage.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
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
            width: 120,
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
}
