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
    
    // Test Firestore connection
    final firestore = FirebaseFirestore.instance;
    await firestore.enableNetwork();
    print('✅ Firestore connected!');
    
    // Try to write test data
    await firestore.collection('test').doc('connection').set({
      'timestamp': DateTime.now(),
      'message': 'Firebase connection working!'
    });
    print('✅ Firestore write test successful!');
    
  } catch (e) {
    print('❌ Firebase connection failed: $e');
  }
  
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: const Center(
        child: Text('Check console for Firebase connection status'),
      ),
    ),
  ));
}
