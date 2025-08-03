// lib/utils/debug_database_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/template_service.dart';

class DebugDatabaseQueryDialog extends StatefulWidget {
  @override
  _DebugDatabaseQueryDialogState createState() => _DebugDatabaseQueryDialogState();
}

class _DebugDatabaseQueryDialogState extends State<DebugDatabaseQueryDialog> {
  String results = 'Click buttons below to test database operations...';
  bool isLoading = false;
  
  Future<void> fixTemplates() async {
    setState(() {
      isLoading = true;
      results = 'Fixing templates...';
    });
    
    try {
      await TemplateService.forceInitializeUserTemplates('douvleplus');
      
      setState(() {
        results = '✅ Templates fixed! User now has proper default templates. Use Query Database to verify.';
        isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        results = '❌ Fix templates failed: $e';
        isLoading = false;
      });
    }
  }

  Future<void> clearTestData() async {
    setState(() {
      isLoading = true;
      results = 'Clearing test data...';
    });
    
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('complete_user_data').doc('douvleplus');
      
      // Get current templates and remove any test templates
      final doc = await userDoc.get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('quick_entry_templates')) {
          final templates = (data['quick_entry_templates'] as List)
              .where((template) => template['name'] != 'Debug Test Template')
              .toList();
          
          await userDoc.update({
            'quick_entry_templates': templates,
          });
        }
      }
      
      setState(() {
        results = '✅ Test data cleared! Use Query Database to verify.';
        isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        results = '❌ Clear test data failed: $e';
        isLoading = false;
      });
    }
  }
  
  Future<void> queryDatabase() async {
    setState(() {
      isLoading = true;
      results = 'Querying Firebase...';
    });
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      String output = '✅ Firebase Connected!\n\n';
      
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
          
          // Check auth fields
          if (data.containsKey('username')) {
            output += '✅ username: ${data['username']}\n';
          } else {
            output += '❌ No username field\n';
          }
          
          if (data.containsKey('password') || data.containsKey('password_hash')) {
            output += '✅ Password field exists\n';
          } else {
            output += '❌ No password/password_hash field\n';
          }
          
          // Check templates
          if (data.containsKey('quick_entry_templates')) {
            final templates = data['quick_entry_templates'];
            output += '✅ quick_entry_templates field exists!\n';
            output += '   Type: ${templates.runtimeType}\n';
            output += '   Value: ${templates}\n';
            
            if (templates is List) {
              output += '   Template count: ${templates.length}\n';
              for (int i = 0; i < templates.length; i++) {
                final template = templates[i];
                output += '   Template $i: ${template}\n';
              }
            }
          } else {
            output += '❌ No quick_entry_templates field\n';
          }
          
          // Show all fields for douvleplus
          output += '\n📋 All douvleplus fields:\n';
          data.forEach((key, value) {
            if (value is List) {
              output += '   $key: List[${value.length}]\n';
            } else if (value is Map) {
              output += '   $key: Map{${value.keys.length} keys}\n';
            } else {
              final shortValue = value.toString().length > 30 
                ? '${value.toString().substring(0, 30)}...'
                : value.toString();
              output += '   $key: $shortValue\n';
            }
          });
        }
      }
      
      // Check other collections
      final rngUsers = await firestore.collection('rng_users').get();
      output += '\n📊 rng_users: ${rngUsers.docs.length} documents\n';
      
      final userData = await firestore.collection('user_data').get();
      output += '📊 user_data: ${userData.docs.length} documents\n';
      
      setState(() {
        results = output;
        isLoading = false;
      });
      
      // Also print to debug console
      print('🔍 DATABASE QUERY RESULTS:');
      print(output);
      
    } catch (e) {
      setState(() {
        results = '❌ Error querying database: $e';
        isLoading = false;
      });
      print('❌ Database query error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Database Debug Tools'),
      content: Container(
        width: 600,
        height: 500,
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : queryDatabase,
                  child: isLoading && results.contains('Querying')
                    ? CircularProgressIndicator()
                    : Text('Query Database'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : clearTestData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: isLoading && results.contains('Clearing')
                    ? CircularProgressIndicator()
                    : Text('Clear Test Data'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  results,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}

// Function to show the debug dialog
void showDatabaseQueryDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => DebugDatabaseQueryDialog(),
  );
}
