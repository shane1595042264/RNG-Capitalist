// scripts/migrate_user_auth.dart
// This script adds authentication fields to existing user documents
// Run this once to enable login for existing users

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';

void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialized');

    final firestore = FirebaseFirestore.instance;
    
    // Get the current douvleplus user document
    final userDoc = await firestore
        .collection('rng_users')
        .doc('douvleplus')
        .get();

    if (!userDoc.exists) {
      print('❌ User douvleplus not found');
      return;
    }

    final userData = userDoc.data()!;
    print('📄 Found user document with ${userData.keys.length} fields');

    // Check if already has authentication fields
    if (userData.containsKey('password_hash')) {
      print('✅ User already has authentication setup');
      return;
    }

    // Prompt for password to set
    print('\n🔑 Setting up authentication for user: douvleplus');
    print('Enter a password for this user (minimum 6 characters):');
    
    String? password;
    while (password == null || password.length < 6) {
      stdout.write('Password: ');
      password = stdin.readLineSync();
      if (password == null || password.length < 6) {
        print('❌ Password must be at least 6 characters');
      }
    }

    // Hash the password (same method as UserAuthService)
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    final passwordHash = hash.toString();

    // Add authentication fields to existing document
    await firestore
        .collection('rng_users')
        .doc('douvleplus')
        .update({
      'username': 'douvleplus', // Keep original username
      'password_hash': passwordHash,
      'created_at': userData['created_at'] ?? FieldValue.serverTimestamp(),
      'last_login': FieldValue.serverTimestamp(),
      'auth_migrated_at': FieldValue.serverTimestamp(),
    });

    print('✅ Authentication fields added successfully!');
    print('📱 You can now login with:');
    print('   Username: douvleplus');
    print('   Password: [the password you just set]');
    print('🎮 All your existing game data has been preserved');

  } catch (e) {
    print('❌ Migration failed: $e');
  }
}
