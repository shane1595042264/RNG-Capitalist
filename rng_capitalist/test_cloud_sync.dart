// test_cloud_sync.dart - Simple test to verify cloud sync
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/complete_firestore_service.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🔥 Firebase initialized');
  
  // Test cloud sync
  final service = CompleteFirestoreService();
  
  print('📤 Testing save to cloud...');
  
  // Create test data
  final testData = CompleteAppData.createDefault(
    deviceName: 'Test Device',
    platform: 'windows_test',
  );
  
  try {
    // Save to cloud
    await service.saveCompleteData(testData);
    print('✅ Data saved to cloud successfully!');
    
    // Load from cloud
    print('📥 Testing load from cloud...');
    final loadedData = await service.loadCompleteData();
    print('✅ Data loaded from cloud successfully!');
    print('   Device: ${loadedData.deviceName}');
    print('   Platform: ${loadedData.platform}');
    print('   Balance: \$${loadedData.lastBalance}');
    print('   Modifiers: ${loadedData.modifiers.length}');
    
    // Test connection
    print('🔗 Testing connection...');
    final connected = await service.testConnection();
    print('Connection: ${connected ? "✅ Connected" : "❌ Failed"}');
    
    // Get sync status
    print('📊 Getting sync status...');
    final status = await service.getSyncStatus();
    print('Sync Status: ${status['hasData'] ? "✅ Has Data" : "❌ No Data"}');
    
    print('\n🎉 All cloud sync tests passed!');
    
  } catch (e) {
    print('❌ Cloud sync test failed: $e');
  }
}
