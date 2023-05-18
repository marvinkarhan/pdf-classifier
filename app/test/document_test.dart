import 'dart:convert';

import 'package:app/model/Document.dart';
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
}
