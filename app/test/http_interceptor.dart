import 'dart:io';

import 'package:nock/nock.dart';
import 'dart:convert';

var _lastCreatedCategory = "";
var _lastCreatedDocument = "";

set lastCreatedCategory(String value) {
  _lastCreatedCategory = value;
}

String get lastCreatedCategory => _lastCreatedCategory;

set lastCreatedDocument(String value) {
  _lastCreatedDocument = value;
}

String get lastCreatedDocument => _lastCreatedDocument;

void mockApis() {
  nock.defaultBase = "http://mock-api/api/v1";

  List<Map<String, dynamic>> documentsStore = [
    {
      "id": "mockIdFile1",
      "title": "mockFileTitle1",
      "content": "mockContent1",
      "distance": 0.80,
      "certainty": 0.69
    },
    {
      "id": "mockIdFile2",
      "title": "mockFileTitle2",
      "content": "mockContent2",
      "distance": 0.70,
      "certainty": 0.59
    },
    {
      "id": "mockIdFile3",
      "title": "mockFileTitle3",
      "content": "mockContent3",
      "distance": 0.60,
      "certainty": 0.49
    },
  ];

  List<Map<String, dynamic>> categoriesStore = [
    {
      "id": "mockIdCat1",
      "title": "mockCatTitle1",
      "parentId": "root",
      "fileIds": ["mockIdFile1"]
    },
    {
      "id": "mockIdCat2",
      "title": "mockCatTitle1",
      "parentId": "mockIdCat2",
      "fileIds": ["mockIdFile2"]
    },
  ];

  nock.get("/document/all")
    ..persist()
    ..reply(200, documentsStore);

  nock.get("/category/all")
    ..persist()
    ..reply(200, categoriesStore);

  nock.post("/document", (body) {
    double nr = documentsStore.length + 1;
    final id = "mockIdFile$nr";
    documentsStore.add({
      "id": id,
      "title": "mockTitle$nr",
      "content": "mockContent$nr",
      "distance": 10 + nr + 1,
      "certainty": 10 + nr + 1,
    });
    lastCreatedDocument = id;
    return true;
  })
    ..persist()
    ..reply(201, true);

  nock.post("/category", (body) {
    String bodyStr = utf8.decode(body);
    Map<String, dynamic> requestBody = jsonDecode(bodyStr);
    // check the fields
    if (requestBody.containsKey('title') &&
        requestBody.containsKey('parentId')) {
      final id = "mockIdCat${categoriesStore.length + 1}";
      categoriesStore.add({
        "id": id,
        "title": requestBody['title'],
        "parentId": requestBody['parentId'],
      });
      lastCreatedCategory = id;
      return true;
    }
    return false;
  })
    ..persist()
    ..reply(201, true);

  nock.get(RegExp(r"^/resource/delete/.*$"))
    ..persist()
    ..reply(200, "Deleted successfully")
    ..onReply(() {
      documentsStore.removeWhere((doc) => doc['id'] == lastCreatedDocument);
      categoriesStore.removeWhere((cat) => cat['id'] == lastCreatedCategory);
      lastCreatedDocument = "";
      lastCreatedCategory = "";
    });

  nock.get(RegExp(r"^/document/query/ERROR$"))
    ..persist()
    ..reply(400, "MOCK ERROR");

  nock.get(RegExp(r"^/document/query/.*$"))
    ..persist()
    ..reply(
        200,
        json.encode(documentsStore
            .map((doc) => {
                  "id": doc['id'],
                  "title": doc['title'],
                  "content": doc['content'],
                  "distance": doc['distance']! - 0.1,
                  "certainty": doc['certainty']! - 0.1,
                })
            .toList()));

  nock.get(RegExp(r"^/document/.*$"))
    ..persist()
    ..reply(200, File('test_resources/sample.pdf').readAsBytesSync().toList());
}
