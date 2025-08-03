import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final doc = await firestore.collection('complete_user_data').doc('douvleplus').get();
    
    if (doc.exists) {
      final data = doc.data();
      print('=== FIREBASE QUERY RESULT ===');
      print('Document exists: ${doc.exists}');
      if (data != null) {
        if (data.containsKey('quick_entry_templates')) {
          final templates = data['quick_entry_templates'] as List?;
          print('Templates field exists: true');
          print('Templates count: ${templates?.length ?? 0}');
          print('Templates data: $templates');
        } else {
          print('Templates field exists: false');
        }
      } else {
        print('Document data is null');
      }
    } else {
      print('Document does not exist');
    }
  } catch (e) {
    print('Error querying Firebase: $e');
  }
}
