import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
    print('Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    
  } catch (e) {
    print('❌ Firebase connection failed: $e');
  }
  
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Firebase Core Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Firebase Core Connection Test'),
            Text('Project: ${DefaultFirebaseOptions.currentPlatform.projectId}'),
          ],
        ),
      ),
    ),
  ));
}
