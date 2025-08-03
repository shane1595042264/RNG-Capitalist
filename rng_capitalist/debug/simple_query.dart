// debug/simple_query.dart
// Simple Flutter app to query Firebase database

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

void main() {
  runApp(DatabaseQueryApp());
}

class DatabaseQueryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Query',
      home: QueryScreen(),
    );
  }
}

class QueryScreen extends StatefulWidget {
  @override
  _QueryScreenState createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  String results = 'Initializing...';
  
  @override
  void initState() {
    super.initState();
    queryFirebase();
  }
  
  Future<void> queryFirebase() async {
    try {
      // Initialize Flutter binding first
      WidgetsFlutterBinding.ensureInitialized();
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      String output = '✅ Firebase Connected!\n\n';
      
      final firestore = FirebaseFirestore.instance;
      
      // Check complete_user_data collection
      final snapshot = await firestore.collection('complete_user_data').get();
      output += '📊 complete_user_data: ${snapshot.docs.length} documents\n';
      
      for (var doc in snapshot.docs) {
        output += '\n📄 Document: ${doc.id}\n';
        final data = doc.data();
        
        // Show all keys
        output += 'Fields: ${data.keys.join(', ')}\n';
        
        if (doc.id == 'douvleplus') {
          output += '\n🎯 DOUVLEPLUS USER DETAILS:\n';
          
          // Check auth
          if (data.containsKey('username')) {
            output += '✅ username: ${data['username']}\n';
          } else {
            output += '❌ No username\n';
          }
          
          if (data.containsKey('password_hash')) {
            output += '✅ password_hash exists\n';
          } else {
            output += '❌ No password_hash\n';
          }
          
          // Check templates
          if (data.containsKey('quick_entry_templates')) {
            final templates = data['quick_entry_templates'];
            output += '✅ quick_entry_templates: ${templates}\n';
          } else {
            output += '❌ No quick_entry_templates field\n';
          }
          
          // Game data
          output += 'Game data:\n';
          output += '  lastBalance: ${data['lastBalance']}\n';
          output += '  sunkCosts: ${(data['sunkCosts'] as List?)?.length ?? 0} items\n';
        }
      }
      
      // Check other collections
      final rngUsers = await firestore.collection('rng_users').get();
      output += '\n📊 rng_users: ${rngUsers.docs.length} documents\n';
      
      setState(() {
        results = output;
      });
      
      // Also print to console
      print(output);
      
    } catch (e) {
      setState(() {
        results = '❌ Error: $e';
      });
      print('❌ Error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Query Results'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            results,
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}
