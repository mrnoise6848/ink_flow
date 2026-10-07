import 'models.dart';

/// Optional extension contract. No provider is installed or called by the core.
/// Implementations must obtain consent before sending any data off device.
abstract interface class DocumentAssistant {
  Future<String> recognizeHandwriting(InkPage page);
  Future<String> summarize(String recognizedText);
  Future<List<String>> extractTasks(String recognizedText);
}
