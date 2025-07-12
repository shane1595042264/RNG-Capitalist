// Simple test to verify DocumentAIService works
import 'lib/services/document_ai_service.dart';

void main() {
  try {
    final service = DocumentAIService();
    print('✅ DocumentAIService imported and instantiated successfully!');
    print('Service instance: $service');
  } catch (e) {
    print('❌ Error: $e');
  }
}
