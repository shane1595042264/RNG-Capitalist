// cloud_sync_windows_test.dart - Cloud sync demo without auth for Windows
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/firestore_service_no_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CloudSyncApp());
}

class CloudSyncApp extends StatelessWidget {
  const CloudSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RNG Capitalist - Cloud Sync Demo (Windows)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CloudSyncPage(),
    );
  }
}

class CloudSyncPage extends StatefulWidget {
  const CloudSyncPage({super.key});

  @override
  _CloudSyncPageState createState() => _CloudSyncPageState();
}

class _CloudSyncPageState extends State<CloudSyncPage> {
  final FirestoreServiceNoAuth _firestoreService = FirestoreServiceNoAuth();
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
      final data = {
        'balance': double.tryParse(_balanceController.text) ?? 0.0,
        'lastMonthSpend': double.tryParse(_spendController.text) ?? 0.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'platform': 'windows',
      };

      await _firestoreService.saveTestData(data);
      setState(() {
        _status = '✅ Saved to cloud successfully!';
        _cloudData = data;
      });
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
      final data = await _firestoreService.loadTestData();
      if (data.isNotEmpty) {
        setState(() {
          _balanceController.text = data['balance']?.toString() ?? '100.0';
          _spendController.text = data['lastMonthSpend']?.toString() ?? '0.0';
          _status = '✅ Loaded from cloud successfully!';
          _cloudData = data;
        });
      } else {
        setState(() {
          _status = 'No cloud data found';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error loading: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RNG Capitalist - Cloud Sync Demo'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                        'Cloud Data',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Balance: \$${_cloudData!['balance']}'),
                      Text('Last Month Spend: \$${_cloudData!['lastMonthSpend']}'),
                      Text('Platform: ${_cloudData!['platform'] ?? 'unknown'}'),
                      if (_cloudData!['timestamp'] != null)
                        Text('Last Updated: ${DateTime.fromMillisecondsSinceEpoch(_cloudData!['timestamp']).toString()}'),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Instructions
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 Cloud Sync is Working!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Change the values above\n'
                      '2. Click "Save to Cloud"\n'
                      '3. Open this on another device\n'
                      '4. Click "Load from Cloud"\n'
                      '5. See your data sync across devices!',
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
