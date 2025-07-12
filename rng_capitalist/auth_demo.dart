// RNG Capitalist with Google Authentication - Web Version
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/auth_service.dart';
import 'lib/services/firestore_service.dart';

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
  
  runApp(const RNGCapitalistAuthApp());
}

class RNGCapitalistAuthApp extends StatelessWidget {
  const RNGCapitalistAuthApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist - Authentication Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const AuthenticatedHomePage();
        }
        
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Successfully signed in!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RNG Capitalist'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.casino,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to RNG Capitalist!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in with Google to sync your data across all devices',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Firebase Project: ${DefaultFirebaseOptions.currentPlatform.projectId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your data will be securely stored in the cloud and synced across all your devices.',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthenticatedHomePage extends StatefulWidget {
  const AuthenticatedHomePage({Key? key}) : super(key: key);

  @override
  State<AuthenticatedHomePage> createState() => _AuthenticatedHomePageState();
}

class _AuthenticatedHomePageState extends State<AuthenticatedHomePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  
  String _savedData = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    try {
      final data = await _firestoreService.loadUserData();
      setState(() {
        _balanceController.text = data.lastBalance.toString();
        _savedData = 'Balance: \$${data.lastBalance}\n'
                    'Month Spend: \$${data.lastMonthSpend}\n'
                    'Fixed Costs: ${data.fixedCosts.length}\n'
                    'Purchase History: ${data.purchaseHistory.length}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data loaded from cloud!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTestData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create test data
      final data = AppDataCloud(
        lastBalance: _balanceController.text.isNotEmpty ? _balanceController.text : '0.0',
        lastMonthSpend: 100.0,
        fixedCosts: [],
        purchaseHistory: [],
        modifiers: [],
        sunkCosts: [],
      );

      await _firestoreService.saveUserData(data);
      
      setState(() {
        _savedData = 'Balance: \$${data.lastBalance}\n'
                    'Month Spend: \$${data.lastMonthSpend}\n'
                    'Last Updated: ${DateTime.now().toString().substring(0, 19)}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💾 Data saved to your cloud account!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sign out failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RNG Capitalist - Authenticated'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundImage: _authService.userPhotoUrl != null
                  ? NetworkImage(_authService.userPhotoUrl!)
                  : null,
              child: _authService.userPhotoUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _authService.userDisplayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _authService.userEmail,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: _signOut,
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: _authService.userPhotoUrl != null
                              ? NetworkImage(_authService.userPhotoUrl!)
                              : null,
                          child: _authService.userPhotoUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${_authService.userDisplayName}!',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Signed in as ${_authService.userEmail}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.verified_user,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Your Balance',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveTestData,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Save to Cloud'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadUserData,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Load from Cloud'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_savedData.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Cloud Data:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(_savedData),
                    ],
                  ),
                ),
              ),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            const Spacer(),
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 Authentication Working!',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Your data is now securely linked to your Google account\n'
                      '• Sign in on any device to access your data\n'
                      '• Ready to integrate with full RNG Capitalist app!',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
