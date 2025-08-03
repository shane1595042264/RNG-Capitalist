// scripts/clear_auth.dart
// Run this to clear cached authentication and test fresh login

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialized');

    // Clear shared preferences (cached login)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    print('✅ Cached authentication cleared');
    print('🔄 Next app launch will require fresh login');
    print('📝 You can now test the login flow with username: douvleplus');

  } catch (e) {
    print('❌ Error clearing auth: $e');
  }
}
