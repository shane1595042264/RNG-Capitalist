// Test script to verify Firebase configuration
// Run this after setting up your Firebase project

import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('✅ Firebase initialized successfully!');
    print('Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    print('Auth Domain: ${DefaultFirebaseOptions.currentPlatform.authDomain}');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('');
    print('Common issues:');
    print('1. Check that firebase_options.dart has your actual configuration values');
    print('2. Make sure Firebase Auth and Firestore are enabled in your Firebase Console');
    print('3. Verify your internet connection');
  }
}
