import 'package:app/model/Config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BackendService {
  String backendUri = "";
  static const String baseApiPath = "/api/v1/";
  static const String getAllDocumentsUri = "$baseApiPath/document/all";
  static const String postDocumentUri = "$baseApiPath/document";
  static const String deleteDocumentByIdUri =
      "$baseApiPath/document/delete"; // uri param :id
  static const String queryDocumentByIdUri =
      "$baseApiPath/document/query"; // uri param :id

  BackendService() {
    backendUri = Config().backendUrl!;
  }

  Future<http.Response> getAllDocuments() {
    return http
        .get(Uri.parse("$backendUri/${BackendService.getAllDocumentsUri})"));
  }

  Future<http.StreamedResponse> postDocument(PlatformFile file) {
    final uri = Uri.parse("$backendUri/${BackendService.postDocumentUri}");
    final bytes = file.bytes!;
    var request = http.MultipartRequest("POST", uri);
    final doc = http.MultipartFile.fromBytes("file", bytes,
        contentType: MediaType("application", "pdf"));
    request.files.add(doc);
    return request.send();
  }

  Future<http.Response> deleteDocumentById(String id) {
    return http.get(
        Uri.parse("$backendUri/${BackendService.deleteDocumentByIdUri}/$id"));
  }

  Future<http.Response> queryDocumentById(String id) {
    return http.get(
        Uri.parse("$backendUri/${BackendService.queryDocumentByIdUri}/$id"));
  }
}
