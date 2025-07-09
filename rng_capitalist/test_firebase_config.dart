// Test script to verify Firebase configuration
// Run this after setting up your Firebase project

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    if (kDebugMode) {
      print('✅ Firebase initialized successfully!');
      print('Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
      print('Auth Domain: ${DefaultFirebaseOptions.currentPlatform.authDomain}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Firebase initialization failed: $e');
      print('');
      print('Common issues:');
      print('1. Check that firebase_options.dart has your actual configuration values');
      print('2. Verify your Firebase project exists and is active');
      print('3. Ensure all required services are enabled (Auth, Firestore)');
    }
  }
}
