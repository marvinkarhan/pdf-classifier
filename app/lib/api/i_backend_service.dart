import 'package:app/model/Document.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

abstract class BackendService {
  Future<List<Document>> getAllDocuments();
  Future<bool> postDocument(PlatformFile file);
  Future<bool> deleteDocumentById(String id);
  Future<List<Document>> queryDocumentById(String id);
  void setOnError(void Function(String errorMessage)? onError);
}
