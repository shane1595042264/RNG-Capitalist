// Test the working DocAIService
import 'lib/services/doc_ai_service.dart';

void main() {
  try {
    final service = DocAIService();
    print('✅ DocAIService works: $service');
  } catch (e) {
    print('❌ Error: $e');
  }
}
