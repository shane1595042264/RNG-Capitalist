// debug/query_database.dart
// Quick script to see what's actually in your Firebase database

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../lib/firebase_options.dart';

void main() async {
  try {
    // Initialize Flutter binding first
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase with proper options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    final firestore = FirebaseFirestore.instance;
    
    // Query the complete_user_data collection
    print('\n📄 Checking complete_user_data collection...');
    final completeUserDataSnapshot = await firestore.collection('complete_user_data').get();
    print('Found ${completeUserDataSnapshot.docs.length} documents in complete_user_data:');
    for (var doc in completeUserDataSnapshot.docs) {
      print('  - Document ID: ${doc.id}');
      final data = doc.data();
      print('    Keys: ${data.keys.toList()}');
      
      if (doc.id == 'douvleplus') {
        print('    🎯 DOUVLEPLUS DOCUMENT FOUND!');
        print('    Full data keys: ${data.keys.toList()}');
        
        // Check for authentication fields
        if (data.containsKey('password_hash')) {
          print('    ✅ Has password_hash: ${data['password_hash'].toString().substring(0, 10)}...');
        } else {
          print('    ❌ Missing password_hash');
        }
        
        if (data.containsKey('username')) {
          print('    ✅ Has username: ${data['username']}');
        } else {
          print('    ❌ Missing username');
        }
        
        // Check for template fields
        if (data.containsKey('quick_entry_templates')) {
          final templates = data['quick_entry_templates'];
          print('    ✅ Has quick_entry_templates: ${templates.runtimeType}');
          if (templates is List) {
            print('        Templates count: ${templates.length}');
          }
        } else {
          print('    ❌ Missing quick_entry_templates');
        }
        
        // Check other game data
        print('    Game data:');
        print('      - lastBalance: ${data['lastBalance'] ?? 'N/A'}');
        print('      - sunkCosts: ${(data['sunkCosts'] as List?)?.length ?? 0} items');
        print('      - purchaseHistory: ${(data['purchaseHistory'] as List?)?.length ?? 0} items');
        print('      - modifiers: ${(data['modifiers'] as List?)?.length ?? 0} items');
      }
    }
    
    // Query the rng_users collection
    print('\n📄 Checking rng_users collection...');
    final rngUsersSnapshot = await firestore.collection('rng_users').get();
    print('Found ${rngUsersSnapshot.docs.length} documents in rng_users:');
    for (var doc in rngUsersSnapshot.docs) {
      print('  - Document ID: ${doc.id}');
      final data = doc.data();
      print('    Keys: ${data.keys.toList()}');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}
