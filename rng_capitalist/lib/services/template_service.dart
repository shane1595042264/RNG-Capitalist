// lib/services/template_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entry_template.dart';

class TemplateService {
  static const String _collection = 'complete_user_data'; // Use same collection as main data
  static const String _templatesField = 'quick_entry_templates';
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save templates for a specific user
  static Future<void> saveUserTemplates(String userId, List<EntryTemplate> templates) async {
    try {
      print('🔄 Starting template save for user: $userId');
      print('📝 Total templates to save: ${templates.length}');
      
      final userDoc = _firestore.collection(_collection).doc(userId);
      
      // Convert ALL templates to JSON (user now owns all their templates)
      final allTemplates = templates
          .map((template) => template.toJson())
          .toList();
      
      print('💾 All user templates to save: ${allTemplates.length}');
      print('📋 Template data: $allTemplates');
      
      await userDoc.set({
        _templatesField: allTemplates,
      }, SetOptions(merge: true));
      
      print('✅ Templates saved successfully for user: $userId');
      
      // Verify the save worked
      final verifyDoc = await userDoc.get();
      final verifyData = verifyDoc.data();
      if (verifyData != null && verifyData.containsKey(_templatesField)) {
        print('✅ Verification: Templates field exists in database');
        print('📊 Saved templates count: ${(verifyData[_templatesField] as List).length}');
      } else {
        print('❌ Verification FAILED: Templates field not found after save!');
      }
      
    } catch (e) {
      print('❌ Error saving templates: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      throw Exception('Failed to save templates: $e');
    }
  }

  /// Load templates for a specific user
  static Future<List<EntryTemplate>> loadUserTemplates(String userId) async {
    try {
      final userDoc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!userDoc.exists) {
        print('User document does not exist, initializing with default templates');
        return await _initializeUserTemplates(userId);
      }
      
      final data = userDoc.data();
      if (data == null || !data.containsKey(_templatesField)) {
        print('No templates field found, initializing with default templates');
        return await _initializeUserTemplates(userId);
      }
      
      final templatesJson = data[_templatesField] as List<dynamic>?;
      if (templatesJson == null) {
        print('Templates field is null, initializing with default templates');
        return await _initializeUserTemplates(userId);
      }
      
      if (templatesJson.isEmpty) {
        print('User has intentionally cleared all templates, returning empty list');
        return [];
      }
      
      // Parse user's personal templates from JSON
      final userTemplates = templatesJson
          .map((json) => EntryTemplate.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('Loaded ${userTemplates.length} personal templates for user: $userId');
      return userTemplates;
    } catch (e) {
      print('Error loading templates: $e');
      // Initialize with defaults if there's an error
      return await _initializeUserTemplates(userId);
    }
  }

  /// Initialize user with their own copy of default templates (as non-default/editable)
  static Future<List<EntryTemplate>> _initializeUserTemplates(String userId) async {
    try {
      // Create user's personal copy of default templates (make them editable)
      final personalTemplates = EntryTemplate.getDefaultTemplates()
          .map((template) => EntryTemplate(
                name: template.name,
                description: template.description,
                amount: template.amount,
                isAddition: template.isAddition,
                isDefault: false, // Make them editable by removing default flag
              ))
          .toList();
      
      // Save them to the user's account
      await saveUserTemplates(userId, personalTemplates);
      
      print('✅ Initialized ${personalTemplates.length} personal templates for user: $userId');
      return personalTemplates;
    } catch (e) {
      print('❌ Error initializing user templates: $e');
      // Fallback to default templates (but user won't be able to edit them)
      return EntryTemplate.getDefaultTemplates();
    }
  }

  /// Force initialize user templates (for existing users who don't have proper defaults)
  static Future<void> forceInitializeUserTemplates(String userId) async {
    try {
      print('🔄 Force initializing templates for user: $userId');
      
      // Get current templates
      final userDoc = await _firestore.collection(_collection).doc(userId).get();
      List<EntryTemplate> existingTemplates = [];
      
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey(_templatesField)) {
          final templatesJson = data[_templatesField] as List<dynamic>?;
          if (templatesJson != null) {
            existingTemplates = templatesJson
                .map((json) => EntryTemplate.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
      }
      
      // Create default templates as editable
      final defaultTemplates = EntryTemplate.getDefaultTemplates()
          .map((template) => EntryTemplate(
                name: template.name,
                description: template.description,
                amount: template.amount,
                isAddition: template.isAddition,
                isDefault: false, // Make them editable
              ))
          .toList();
      
      // Combine existing custom templates with defaults (avoid duplicates)
      final allTemplates = <EntryTemplate>[
        ...defaultTemplates,
        ...existingTemplates.where((existing) => 
          !defaultTemplates.any((def) => def.name == existing.name))
      ];
      
      // Save the combined list
      await saveUserTemplates(userId, allTemplates);
      
      print('✅ Force initialized ${allTemplates.length} templates for user: $userId');
    } catch (e) {
      print('❌ Error force initializing templates: $e');
    }
  }

  /// Delete all custom templates for a user (keeps defaults)
  static Future<void> clearUserTemplates(String userId) async {
    try {
      final userDoc = _firestore.collection(_collection).doc(userId);
      
      await userDoc.update({
        _templatesField: [],
      });
      
      print('Custom templates cleared for user: $userId');
    } catch (e) {
      print('Error clearing templates: $e');
      throw Exception('Failed to clear templates: $e');
    }
  }

  /// Get a real-time stream of templates for a user
  static Stream<List<EntryTemplate>> watchUserTemplates(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return EntryTemplate.getDefaultTemplates();
      }
      
      final data = snapshot.data();
      if (data == null || !data.containsKey(_templatesField)) {
        return EntryTemplate.getDefaultTemplates();
      }
      
      final templatesJson = data[_templatesField] as List<dynamic>?;
      if (templatesJson == null) {
        return EntryTemplate.getDefaultTemplates();
      }
      
      try {
        // Parse custom templates from JSON
        final customTemplates = templatesJson
            .map((json) => EntryTemplate.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Combine default templates with custom templates
        return <EntryTemplate>[
          ...EntryTemplate.getDefaultTemplates(),
          ...customTemplates,
        ];
      } catch (e) {
        print('Error parsing templates from stream: $e');
        return EntryTemplate.getDefaultTemplates();
      }
    });
  }

  /// Check if user has any custom templates
  static Future<bool> hasCustomTemplates(String userId) async {
    try {
      final userDoc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!userDoc.exists) return false;
      
      final data = userDoc.data();
      if (data == null || !data.containsKey(_templatesField)) return false;
      
      final templatesJson = data[_templatesField] as List<dynamic>?;
      return templatesJson != null && templatesJson.isNotEmpty;
    } catch (e) {
      print('Error checking custom templates: $e');
      return false;
    }
  }
}
