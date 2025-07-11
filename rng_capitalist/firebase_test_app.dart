import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

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
  
  runApp(const FirebaseTestApp());
}

class FirebaseTestApp extends StatelessWidget {
  const FirebaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirebaseTestPage(),
    );
  }
}

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  String _status = 'Testing Firebase connection...';
  
  @override
  void initState() {
    super.initState();
    _testFirebase();
  }
  
  Future<void> _testFirebase() async {
    try {
      // Test Firebase Core
      final app = Firebase.app();
      print('Firebase app name: ${app.name}');
      print('Firebase options: ${app.options.projectId}');
      
      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      await firestore.enableNetwork();
      
      setState(() {
        _status = '✅ Firebase Core and Firestore connected successfully!\n\n'
            'Project ID: ${app.options.projectId}\n'
            'Auth Domain: ${app.options.authDomain}\n'
            'Storage Bucket: ${app.options.storageBucket}';
      });
      
    } catch (e) {
      setState(() {
        _status = '❌ Firebase connection failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Connection Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _testFirestore,
              child: const Text('Test Firestore Write'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _testFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Hello from RNG Capitalist!',
        'platform': 'Windows (Web)'
      });
      
      setState(() {
        _status = _status + '\n\n✅ Firestore write test successful!';
      });
    } catch (e) {
      setState(() {
        _status = _status + '\n\n❌ Firestore write test failed: $e';
      });
    }
  }
}
