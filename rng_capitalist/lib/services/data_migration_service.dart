import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../utils/storage_utils_dnd.dart';
import '../models/fixed_cost.dart';
import '../models/purchase_history.dart';
import '../models/dice_modifier.dart';
import '../models/sunk_cost.dart';

class DataMigrationService {
  final FirestoreService _firestoreService = FirestoreService();
  
  /// Migrate local data to cloud storage
  Future<void> migrateLocalDataToCloud() async {
    try {
      // Load existing local data
      final localData = await StorageUtilsDnD.loadSettings();
      
      // Convert to cloud format
      final cloudData = AppDataCloud(
        lastBalance: localData.lastBalance,
        lastMonthSpend: localData.lastMonthSpend,
        fixedCosts: localData.fixedCosts,
        purchaseHistory: localData.purchaseHistory,
        modifiers: localData.modifiers,
        sunkCosts: localData.sunkCosts,
      );
      
      // Check if cloud data exists
      final existingCloudData = await _firestoreService.loadUserData();
      
      // Only migrate if cloud data is empty or older
      if (existingCloudData.purchaseHistory.isEmpty && 
          localData.purchaseHistory.isNotEmpty) {
        await _firestoreService.saveUserData(cloudData);
        
        if (kDebugMode) {
          print('Successfully migrated local data to cloud');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error migrating data: $e');
      }
      // Don't throw error - let app continue with local data
    }
  }
  
  /// Load data with fallback to local storage
  Future<AppDataCloud> loadDataWithFallback() async {
    try {
      // Try to load from cloud first
      final cloudData = await _firestoreService.loadUserData();
      
      // If cloud data exists, return it
      if (cloudData.purchaseHistory.isNotEmpty || 
          cloudData.fixedCosts.isNotEmpty || 
          cloudData.lastBalance.isNotEmpty) {
        return cloudData;
      }
      
      // Otherwise, load from local storage
      final localData = await StorageUtilsDnD.loadSettings();
      return AppDataCloud(
        lastBalance: localData.lastBalance,
        lastMonthSpend: localData.lastMonthSpend,
        fixedCosts: localData.fixedCosts,
        purchaseHistory: localData.purchaseHistory,
        modifiers: localData.modifiers,
        sunkCosts: localData.sunkCosts,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
      
      // Final fallback - return empty data
      return AppDataCloud(
        lastBalance: '',
        lastMonthSpend: 0.0,
        fixedCosts: [],
        purchaseHistory: [],
        modifiers: [],
        sunkCosts: [],
      );
    }
  }
  
  /// Save data to both cloud and local storage (during transition)
  Future<void> saveDataWithBackup(AppDataCloud data) async {
    try {
      // Save to cloud
      await _firestoreService.saveUserData(data);
      
      // Also save to local storage as backup
      final localData = AppDataDnD(
        lastBalance: data.lastBalance,
        lastMonthSpend: data.lastMonthSpend,
        fixedCosts: data.fixedCosts,
        purchaseHistory: data.purchaseHistory,
        modifiers: data.modifiers,
        sunkCosts: data.sunkCosts,
      );
      
      await StorageUtilsDnD.saveSettings(localData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving data: $e');
      }
      rethrow;
    }
  }
}
