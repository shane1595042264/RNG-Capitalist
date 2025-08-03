// Clear debug template script
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('complete_user_data').doc('douvleplus');
    
    // Clear templates completely
    await userDoc.update({
      'quick_entry_templates': [],
    });
    
    print('✅ Debug template cleared!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
