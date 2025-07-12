// Simple Cloud Sync Test App
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/firestore_service_no_auth.dart';

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
  
  runApp(const CloudSyncTestApp());
}

class CloudSyncTestApp extends StatelessWidget {
  const CloudSyncTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Sync Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CloudSyncTestPage(),
    );
  }
}

class CloudSyncTestPage extends StatefulWidget {
  const CloudSyncTestPage({Key? key}) : super(key: key);

  @override
  State<CloudSyncTestPage> createState() => _CloudSyncTestPageState();
}

class _CloudSyncTestPageState extends State<CloudSyncTestPage> {
  final FirestoreServiceNoAuth _firestoreService = FirestoreServiceNoAuth();
  final TextEditingController _textController = TextEditingController();
  
  String _status = 'Ready to test cloud sync';
  String _savedData = '';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Firestore connection...';
    });

    try {
      final connected = await _firestoreService.testConnection();
      setState(() {
        _status = connected 
          ? '✅ Firestore connection successful!'
          : '❌ Firestore connection failed';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Connection test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTestData() async {
    if (_textController.text.isEmpty) {
      setState(() {
        _status = '⚠️ Please enter some text to save';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Saving data to cloud...';
    });

    try {
      // Create dummy data with the text
      final data = AppDataCloudNoAuth(
        lastBalance: double.tryParse(_textController.text) ?? 42.0,
        lastMonthSpend: 100.0,
        fixedCosts: [],
        purchaseHistory: [],
        modifiers: [],
        sunkCosts: [],
      );

      await _firestoreService.saveUserData(data);
      setState(() {
        _status = '✅ Data saved to cloud successfully!';
        _savedData = 'Balance: \$${data.lastBalance}';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed to save data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTestData() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading data from cloud...';
    });

    try {
      final data = await _firestoreService.loadUserData();
      if (data != null) {
        setState(() {
          _status = '✅ Data loaded from cloud successfully!';
          _savedData = 'Balance: \$${data.lastBalance}\nMonth Spend: \$${data.lastMonthSpend}';
          _textController.text = data.lastBalance.toString();
        });
      } else {
        setState(() {
          _status = 'ℹ️ No data found in cloud';
          _savedData = '';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Failed to load data: $e';
        _savedData = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Firebase Project: ${DefaultFirebaseOptions.currentPlatform.projectId}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _status.startsWith('✅') ? Colors.green :
                               _status.startsWith('❌') ? Colors.red :
                               _status.startsWith('⚠️') ? Colors.orange :
                               null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter a number (will be saved as balance)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testConnection,
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Test Connection'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveTestData,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Save to Cloud'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadTestData,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Load from Cloud'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_savedData.isNotEmpty)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Data:',
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
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Test the connection first\n'
                      '2. Enter a number and save to cloud\n'
                      '3. Try loading from cloud\n'
                      '4. Run this app on another device to test sync!',
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
