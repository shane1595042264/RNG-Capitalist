// Test file directly in services directory
import 'document_ai_service.dart';

void main() {
  try {
    final service = DocumentAIService();
    print('✅ DocumentAIService works: $service');
  } catch (e) {
    print('❌ Error: $e');
  }
}
