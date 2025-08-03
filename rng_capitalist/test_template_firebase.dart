// test_template_firebase.dart
// Run this in the terminal with: dart run lib/test_template_firebase.dart

import 'package:firebase_core/firebase_core.dart';
import 'lib/services/template_service.dart';
import 'lib/models/entry_template.dart';
import 'lib/firebase_options.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('🔥 Firebase initialized');

  const userId = 'douvleplus';

  // Test loading templates
  print('\n📥 Loading templates...');
  final templates = await TemplateService.loadUserTemplates(userId);
  print('✅ Loaded ${templates.length} templates:');
  for (var template in templates) {
    print('  - ${template.name}: \$${template.amount} (${template.isAddition ? 'Add' : 'Subtract'})');
  }

  // Test adding a new template
  print('\n➕ Adding a new template...');
  final newTemplates = [
    ...templates,
    EntryTemplate(
      name: 'Test Firebase Template',
      description: 'A test template added via Firebase',
      amount: 25.0,
      isAddition: true,
    ),
  ];

  await TemplateService.saveUserTemplates(userId, newTemplates);
  print('✅ Template added to Firebase');

  // Verify the new template was saved
  print('\n🔍 Verifying templates were saved...');
  final updatedTemplates = await TemplateService.loadUserTemplates(userId);
  print('✅ Now have ${updatedTemplates.length} templates:');
  for (var template in updatedTemplates) {
    print('  - ${template.name}: \$${template.amount} (${template.isAddition ? 'Add' : 'Subtract'})');
  }

  print('\n🎉 Template Firebase integration test complete!');
}
