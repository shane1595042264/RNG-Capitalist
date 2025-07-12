// lib/services/document_ai_service.dart - Minimal working version

class DocumentAIService {
  static final DocumentAIService _instance = DocumentAIService._internal();
  factory DocumentAIService() => _instance;
  DocumentAIService._internal();

  Future<String> test() async {
    return 'DocumentAIService is working!';
  }
}
