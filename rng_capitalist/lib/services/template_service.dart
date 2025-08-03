// lib/services/template_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entry_template.dart';

class TemplateService {
  static const String _collection = 'rng_users'; // Use existing collection structure
  static const String _templatesField = 'quick_entry_templates';
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save templates for a specific user
  static Future<void> saveUserTemplates(String userId, List<EntryTemplate> templates) async {
    try {
      final userDoc = _firestore.collection(_collection).doc(userId);
      
      // Convert templates to JSON, excluding default templates
      final customTemplates = templates
          .where((template) => !template.isDefault)
          .map((template) => template.toJson())
          .toList();
      
      await userDoc.set({
        _templatesField: customTemplates,
      }, SetOptions(merge: true));
      
      print('Templates saved successfully for user: $userId');
    } catch (e) {
      print('Error saving templates: $e');
      throw Exception('Failed to save templates: $e');
    }
  }

  /// Load templates for a specific user
  static Future<List<EntryTemplate>> loadUserTemplates(String userId) async {
    try {
      final userDoc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!userDoc.exists) {
        print('User document does not exist, returning default templates');
        return EntryTemplate.getDefaultTemplates();
      }
      
      final data = userDoc.data();
      if (data == null || !data.containsKey(_templatesField)) {
        print('No templates field found, returning default templates');
        return EntryTemplate.getDefaultTemplates();
      }
      
      final templatesJson = data[_templatesField] as List<dynamic>?;
      if (templatesJson == null) {
        print('Templates field is null, returning default templates');
        return EntryTemplate.getDefaultTemplates();
      }
      
      // Parse custom templates from JSON
      final customTemplates = templatesJson
          .map((json) => EntryTemplate.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Combine default templates with custom templates
      final allTemplates = <EntryTemplate>[
        ...EntryTemplate.getDefaultTemplates(),
        ...customTemplates,
      ];
      
      print('Loaded ${customTemplates.length} custom templates for user: $userId');
      return allTemplates;
    } catch (e) {
      print('Error loading templates: $e');
      // Return default templates if there's an error
      return EntryTemplate.getDefaultTemplates();
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
