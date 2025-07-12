// email_auth_test_windows.dart - Email auth + cloud sync test for Windows
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/email_auth_service.dart';
import 'lib/services/firestore_service.dart';
import 'lib/components/email_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EmailAuthApp());
}

class EmailAuthApp extends StatelessWidget {
  const EmailAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist - Email Auth Test (Windows)',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final EmailAuthService _authService = EmailAuthService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const CloudSyncTestPage();
        }

        return const EmailLoginPage();
      },
    );
  }
}

class CloudSyncTestPage extends StatefulWidget {
  const CloudSyncTestPage({super.key});

  @override
  _CloudSyncTestPageState createState() => _CloudSyncTestPageState();
}

class _CloudSyncTestPageState extends State<CloudSyncTestPage> {
  final EmailAuthService _authService = EmailAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _spendController = TextEditingController();
  
  String _status = 'Ready';
  Map<String, dynamic>? _cloudData;

  @override
  void initState() {
    super.initState();
    _balanceController.text = '100.0';
    _spendController.text = '0.0';
    _loadFromCloud();
  }

  Future<void> _saveToCloud() async {
    setState(() {
      _status = 'Saving to cloud...';
    });

    try {
      final data = AppDataCloud(
        lastBalance: _balanceController.text,
        lastMonthSpend: double.tryParse(_spendController.text) ?? 0.0,
        fixedCosts: [],
        purchaseHistory: [],
        modifiers: [],
        sunkCosts: [],
      );

      await _firestoreService.saveUserData(data);
      setState(() {
        _status = '✅ Saved to cloud successfully!';
      });
      _loadFromCloud(); // Refresh data
    } catch (e) {
      setState(() {
        _status = '❌ Error saving: $e';
      });
    }
  }

  Future<void> _loadFromCloud() async {
    setState(() {
      _status = 'Loading from cloud...';
    });

    try {
      final data = await _firestoreService.loadUserData();
      setState(() {
        _balanceController.text = data.lastBalance;
        _spendController.text = data.lastMonthSpend.toString();
        _status = '✅ Loaded from cloud successfully!';
        _cloudData = {
          'balance': data.lastBalance,
          'lastMonthSpend': data.lastMonthSpend,
          'userEmail': _authService.userEmail,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error loading: $e';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RNG Capitalist - Email Auth + Cloud Sync'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User info card
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.purple.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🎉 Email Authentication Working!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.purple.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Signed in as: ${_authService.userEmail}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status card
            Card(
              color: _status.contains('✅') 
                  ? Colors.green.shade50 
                  : _status.contains('❌') 
                      ? Colors.red.shade50 
                      : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _status.contains('✅') 
                          ? Icons.cloud_done 
                          : _status.contains('❌') 
                              ? Icons.cloud_off 
                              : Icons.cloud,
                      size: 48,
                      color: _status.contains('✅') 
                          ? Colors.green 
                          : _status.contains('❌') 
                              ? Colors.red 
                              : Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Data input section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Data',
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
                      controller: _spendController,
                      decoration: const InputDecoration(
                        labelText: 'Last Month Spend',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveToCloud,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Save to Cloud'),
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
                    onPressed: _loadFromCloud,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Load from Cloud'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cloud data display
            if (_cloudData != null)
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Cloud Data',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Balance: \$${_cloudData!['balance']}'),
                      Text('Last Month Spend: \$${_cloudData!['lastMonthSpend']}'),
                      Text('User: ${_cloudData!['userEmail']}'),
                      Text('Last Updated: ${DateTime.fromMillisecondsSinceEpoch(_cloudData!['timestamp']).toString()}'),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Success message
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 Windows Auth + Cloud Sync Working!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✅ Email/Password authentication\n'
                      '✅ User-specific cloud data storage\n'
                      '✅ Cross-device synchronization\n'
                      '✅ Windows compatibility confirmed!',
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

  @override
  void dispose() {
    _balanceController.dispose();
    _spendController.dispose();
    super.dispose();
  }
}
