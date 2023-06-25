import 'dart:convert';

import 'package:app/model/category.dart';
import 'package:app/model/document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Document json should be parsed successfully", () {
    String json =
        '[{"content": "TEST CONTENT 123","id": "de5bf620-19a4-448d-ad08-b54744c6aba0","title": "parsing_test.pdf"},{"content": "TEST CONTENT 256","id": "xe5bf620-19a4-448d-ad08-b54744c6aba0","title": "parsing_test2.pdf"}]';
    List parsed = jsonDecode(json);
    expect(parsed.length, 2);
    Document doc1 = Document.fromJson(parsed[0]);
    Document doc2 = Document.fromJson(parsed[1]);

    expect(doc1.title, "parsing_test.pdf");
    expect(doc1.content, "TEST CONTENT 123");
    expect(doc1.id, "de5bf620-19a4-448d-ad08-b54744c6aba0");

    expect(doc2.title, "parsing_test2.pdf");
    expect(doc2.content, "TEST CONTENT 256");
    expect(doc2.id, "xe5bf620-19a4-448d-ad08-b54744c6aba0");
  });

  test("Category json should be parsed successfully", () {
    String json = '[{"fileIds": ["1027c096-937a-4e68-9024-939d5075ca58"],"id": "293a8eda-fb9c-41ca-ba03-32584963e95d","parentId": "root","title": "testTitle1"},{"fileIds": ["3fb41682-2a4b-40d1-a351-239e183915a2","9bef5a16-42db-4b1c-b8cb-65fd7ad131cf"],"id": "72c5d07b-8422-4e80-bc0b-0734e26f107d","parentId": "root","title": "testTitle2"}]';
    List parsed = jsonDecode(json);
    expect(parsed.length, 2);
    Category cat1 = Category.fromJson(parsed[0]);
    Category cat2 = Category.fromJson(parsed[1]);

    expect(cat1.title, "testTitle1");
    expect(cat1.parentId, "root");
    expect(cat1.fileIds?.length, 1);
    expect(cat1.fileIds?[0], "1027c096-937a-4e68-9024-939d5075ca58");
    expect(cat1.id, "293a8eda-fb9c-41ca-ba03-32584963e95d");

    expect(cat2.title, "testTitle2");
    expect(cat2.parentId, "root");
    expect(cat2.fileIds?.length, 2);
    expect(cat2.fileIds?[0], "3fb41682-2a4b-40d1-a351-239e183915a2");
    expect(cat2.fileIds?[1], "9bef5a16-42db-4b1c-b8cb-65fd7ad131cf");
    expect(cat2.id, "72c5d07b-8422-4e80-bc0b-0734e26f107d");
  });
}
