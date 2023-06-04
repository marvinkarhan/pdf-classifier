import 'package:app/model/Category.dart';
import 'package:app/model/Document.dart';
import 'package:file_picker/file_picker.dart';

abstract class BackendService {
  Future<List<Document>> getAllDocuments();
  Future<bool> postDocument(PlatformFile file);
  Future<bool> deleteResourceById(String id);
  Future<List<Document>> queryDocumentById(String id);
  Future<String> downloadDocumentById(String id);
  Future<List<Category>> getAllCategories();
  Future<bool> postCategory(String title, String? parentId);
  void setOnError(void Function(String errorMessage)? onError);
}
