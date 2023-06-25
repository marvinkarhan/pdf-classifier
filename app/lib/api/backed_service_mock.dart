import 'dart:io';

import 'package:app/api/i_backend_service.dart';
import 'package:app/model/category.dart';
import 'package:app/model/document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class BackendServiceMock implements BackendService {
  final Document _mockDoc1 = Document(
      id: "mockIdFile1",
      title: "mockFileTitle1",
      content: "mockContent1",
      distance: 0.80,
      certainty: 0.69);
  final Document _mockDoc2 = Document(
      id: "mockIdFile2",
      title: "mockFileTitle2",
      content: "mockContent2",
      distance: 0.70,
      certainty: 0.59);
  final Document _mockDoc3 = Document(
      id: "mockIdFile3",
      title: "mockFileTitle3",
      content: "mockContent3",
      distance: 0.60,
      certainty: 0.49);
  final Category _mockCat1 = Category(
      id: "mockIdCat1",
      title: "mockCatTitle1",
      parentId: "root",
      fileIds: ["mockIdFile1"]);
  final Category _mockCat2 = Category(
      id: "mockIdCat2",
      title: "mockCatTitle1",
      parentId: "mockIdCat2",
      fileIds: ["mockIdFile2"]);
  List<Document> documentsStore = [];
  List<Category> categoriesStore = [];
  void Function(String message)? onError;

  BackendServiceMock() {
    documentsStore.add(_mockDoc1);
    documentsStore.add(_mockDoc2);
    documentsStore.add(_mockDoc3);
    categoriesStore.add(_mockCat1);
    categoriesStore.add(_mockCat2);
  }
  @override
  Future<bool> deleteResourceById(String id) async {
    for (var element in documentsStore) {
      if (element.id == id) {
        return documentsStore.remove(element);
      }
    }
    for (var element in categoriesStore) {
      if (element.id == id) {
        return categoriesStore.remove(element);
      }
    }
    return false;
  }

  @override
  Future<String> downloadDocumentById(String id) async {
    File sourceFile = File('test_resources/sample.pdf');

    return sourceFile.path;
  }

  @override
  Future<List<Document>> getAllDocuments() async {
    return documentsStore;
  }

  @override
  Future<bool> postDocument(PlatformFile file) async {
    double nr = documentsStore.length + 1;
    Document newDoc = Document(
        id: "mockId$nr",
        title: "mockTitle$nr",
        content: "mockContent$nr",
        distance: 10 + nr,
        certainty: 10 + nr);
    documentsStore.add(newDoc);
    return true;
  }

  @override
  Future<List<Document>> queryDocumentById(String id) async {
    if (id == "ERROR") {
      onError?.call("MOCK ERROR");
      return [];
    }
    List<Document> mockDocuments = [];
    mockDocuments = await getAllDocuments();
    for (var element in mockDocuments) {
      element.distance = element.distance! - 0.1;
      element.certainty = element.certainty! - 0.1;
    }
    return mockDocuments;
  }

  @override
  void setOnError(void Function(String errorMessage)? onError) {
    this.onError = onError;
  }

  @override
  Future<List<Category>> getAllCategories() async {
    return categoriesStore;
  }

  @override
  Future<bool> postCategory(String title, String? parentId) async {
    int nr = categoriesStore.length + 1;
    Category newCat =
        Category(id: "mockIdCat$nr", title: "mockTitle$nr", parentId: parentId);
    categoriesStore.add(newCat);
    return true;
  }
}
