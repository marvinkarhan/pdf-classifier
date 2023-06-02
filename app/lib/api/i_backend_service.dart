import 'package:app/model/Document.dart';
import 'package:file_picker/file_picker.dart';

abstract class BackendService {
  Future<List<Document>> getAllDocuments();
  Future<bool> postDocument(PlatformFile file);
  Future<bool> deleteDocumentById(String id);
  Future<List<Document>> queryDocumentById(String id);
  Future<String> downloadDocumentById(String id);
  void setOnError(void Function(String errorMessage)? onError);
}
