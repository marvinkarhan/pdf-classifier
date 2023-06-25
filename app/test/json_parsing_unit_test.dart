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
    Document doc1Parsed = Document.fromJson(parsed[0]);
    Document doc1 = Document(
        id: "de5bf620-19a4-448d-ad08-b54744c6aba0",
        title: "parsing_test.pdf",
        content: "TEST CONTENT 123");
    Document doc2Parsed = Document.fromJson(parsed[1]);
    Document doc2 = Document(
        id: "xe5bf620-19a4-448d-ad08-b54744c6aba0",
        title: "parsing_test2.pdf",
        content: "TEST CONTENT 256");

    expect(doc1Parsed.toString(), doc1.toString());
    expect(doc2Parsed.toString(), doc2.toString());

    expect(doc1Parsed.title, "parsing_test.pdf");
    expect(doc1Parsed.content, "TEST CONTENT 123");
    expect(doc1Parsed.id, "de5bf620-19a4-448d-ad08-b54744c6aba0");

    expect(doc2Parsed.title, "parsing_test2.pdf");
    expect(doc2Parsed.content, "TEST CONTENT 256");
    expect(doc2Parsed.id, "xe5bf620-19a4-448d-ad08-b54744c6aba0");
  });

  test("Category json should be parsed successfully", () {
    String json =
        '[{"fileIds": ["1027c096-937a-4e68-9024-939d5075ca58"],"id": "293a8eda-fb9c-41ca-ba03-32584963e95d","parentId": "root","title": "testTitle1"},{"fileIds": ["3fb41682-2a4b-40d1-a351-239e183915a2","9bef5a16-42db-4b1c-b8cb-65fd7ad131cf"],"id": "72c5d07b-8422-4e80-bc0b-0734e26f107d","parentId": "root","title": "testTitle2"}]';
    List parsed = jsonDecode(json);
    expect(parsed.length, 2);
    Category cat1Parsed = Category.fromJson(parsed[0]);
    Category cat1 = Category(
        id: "293a8eda-fb9c-41ca-ba03-32584963e95d",
        title: "testTitle1",
        parentId: "root",
        fileIds: ["1027c096-937a-4e68-9024-939d5075ca58"]);
    Category cat2Parsed = Category.fromJson(parsed[1]);
    Category cat2 = Category(
        id: "72c5d07b-8422-4e80-bc0b-0734e26f107d",
        title: "testTitle2",
        parentId: "root",
        fileIds: [
          "3fb41682-2a4b-40d1-a351-239e183915a2",
          "9bef5a16-42db-4b1c-b8cb-65fd7ad131cf"
        ]);

    expect(cat1Parsed.toString(), cat1.toString());
    expect(cat2Parsed.toString(), cat2.toString());

    expect(cat1Parsed.title, "testTitle1");
    expect(cat1Parsed.parentId, "root");
    expect(cat1Parsed.fileIds?.length, 1);
    expect(cat1Parsed.fileIds?[0], "1027c096-937a-4e68-9024-939d5075ca58");
    expect(cat1Parsed.id, "293a8eda-fb9c-41ca-ba03-32584963e95d");

    expect(cat2Parsed.title, "testTitle2");
    expect(cat2Parsed.parentId, "root");
    expect(cat2Parsed.fileIds?.length, 2);
    expect(cat2Parsed.fileIds?[0], "3fb41682-2a4b-40d1-a351-239e183915a2");
    expect(cat2Parsed.fileIds?[1], "9bef5a16-42db-4b1c-b8cb-65fd7ad131cf");
    expect(cat2Parsed.id, "72c5d07b-8422-4e80-bc0b-0734e26f107d");
  });
}
