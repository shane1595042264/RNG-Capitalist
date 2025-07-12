// Test the working DocAIService

void main() {
  try {
    final service = DocAIService();
    print('✅ DocAIService works: $service');
  } catch (e) {
    print('❌ Error: $e');
  }
}
