import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app/api/i_backend_service.dart';
import 'package:app/model/Category.dart';
import 'package:app/model/Config.dart';
import 'package:app/model/Document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

class BackendServiceImpl implements BackendService {
  String backendUri = "";
  static const String baseApiPath = "/api/v1";
  static const String getAllDocumentsUri = "$baseApiPath/document/all";
  static const String postDocumentUri = "$baseApiPath/document";
  static const String deleteResourceByIdUri =
      "$baseApiPath/resource/delete"; // uri param :id
  static const String queryDocumentByIdUri =
      "$baseApiPath/document/query"; // uri param :id
  static const String downloadDocumentByIdUri =
      "$baseApiPath/document"; // uri param :id
  static const String getAllCategoriesUri = "$baseApiPath/category/all";
  static const String postCategoryUri = "$baseApiPath/category";

  void Function(String message)? onError;

  BackendServiceImpl() {
    backendUri = Config().backendUrl!;
  }

  @override
  Future<List<Document>> getAllDocuments() async {
    log("Fetching all documents");
    http.Response res = await http
        .get(Uri.parse("$backendUri${BackendServiceImpl.getAllDocumentsUri}"));
    if (res.statusCode != 201 && res.statusCode != 200) {
      onError?.call("Error during document fetch, cannot get documents");
      return [];
    }
    List parsedRes = jsonDecode(res.body);
    List<Document> docs = parsedRes.map((e) => Document.fromJson(e)).toList();
    log("Fetched all documents successfully");
    return docs;
  }

  @override
  Future<bool> postDocument(PlatformFile file) async {
    final uri = Uri.parse("$backendUri${BackendServiceImpl.postDocumentUri}");
    log("Uploading file ${file.name} to backend");
    final bytes = file.bytes!;
    var request = http.MultipartRequest("POST", uri);
    final doc = http.MultipartFile.fromBytes("file", bytes,
        filename: file.name, contentType: MediaType("application", "pdf"));
    request.files.add(doc);
    var streamedRes = await request.send();
    var res = await http.Response.fromStream(streamedRes);
    log("Status: ${res.statusCode.toString()}");
    if (res.statusCode != 201 && res.statusCode != 200) {
      onError?.call("Error during document upload, will be ignored");
      return false;
    }
    return true;
  }

  @override
  Future<bool> deleteResourceById(String id) async {
    log("Deleting file $id");
    var res = await http.get(Uri.parse(
        "$backendUri${BackendServiceImpl.deleteResourceByIdUri}/$id"));
    if (res.statusCode != 201 && res.statusCode != 200) {
      onError?.call("Error during resource delete, cannot delete resource");
      return false;
    }
    log("Deleted resource $id successfully");
    return true;
  }

  @override
  Future<List<Document>> queryDocumentById(String id) async {
    log("Query for documents");
    http.Response res = await http.get(
        Uri.parse("$backendUri${BackendServiceImpl.queryDocumentByIdUri}/$id"));
    if (res.statusCode != 201 && res.statusCode != 200) {
      onError?.call("Error during document fetch, cannot query documents");
      return [];
    }
    List parsedRes = jsonDecode(res.body);
    List<Document> docs = parsedRes.map((e) => Document.fromJson(e)).toList();
    log("Queried for documents successfully");
    return docs;
  }

  @override
  Future<String> downloadDocumentById(String id) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File checkFile = File('$dir/$id');
    if (checkFile.existsSync() == true) {
      return checkFile.path;
    }
    log("Downloading document $id");
    final res = await http.get(Uri.parse(
        "$backendUri${BackendServiceImpl.downloadDocumentByIdUri}/$id"));
    if (res.statusCode != 201 && res.statusCode != 200) {
      onError?.call("Error during document fetch, cannot query documents");
      return "";
    }
    var bytes = res.bodyBytes;
    File file = File('$dir/$id');
    await file.writeAsBytes(bytes);
    log("Downloaded document successfully, path: ${file.path}");
    return file.path;
  }

  @override
  Future<List<Category>> getAllCategories() async {
    log("Fetching all categories");
    http.Response res = await http
        .get(Uri.parse("$backendUri${BackendServiceImpl.getAllCategoriesUri}"));
    if (res.statusCode != 201 && res.statusCode != 200) {
      onError?.call("Error during categories fetch, cannot get categories");
      return [];
    }
    List parsedRes = jsonDecode(res.body);
    List<Category> docs = parsedRes.map((e) => Category.fromJson(e)).toList();
    log("Fetched all categories successfully");
    return docs;
  }

  @override
  Future<bool> postCategory(String title, String? parentId) async {
    final uri = Uri.parse("$backendUri${BackendServiceImpl.postCategoryUri}");
    log("Uploading category $title to backend");
    var res = await http.post(uri,
        body: jsonEncode({"title": title, "parentId": parentId}),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        });
    if (res.statusCode != 201 && res.statusCode != 200) {
      onError?.call("Error during category creation, will be ignored");
      log(res.body);
      return false;
    }
    log("Created category successfully");
    return true;
  }

  @override
  void setOnError(void Function(String errorMessage)? onError) {
    this.onError = onError;
  }
}
