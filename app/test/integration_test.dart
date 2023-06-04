import 'package:app/model/Document.dart';

import 'package:app/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  setUpAll(() {
    setupSlMock(); // register mock backend service for dependency injection
  });

  testWidgets('Document Classifier Integration Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text("Document Classifier Home"), findsOneWidget);
    // Check if received and rendered three mock documents
    expect(find.byType(ListTile), findsNWidgets(3));
    // Check if the add file button is there
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // CHeck if text search field is there
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), "MOCK");
    await tester.pump(const Duration(milliseconds: 600));
    Iterable<ListTile> pdfCardWidgets =
        tester.widgetList(find.byType(ListTile));
    // Check if we have gotten and displayed the queried documents
    // for (var element in pdfCardWidgets) {
    //   Document doc = element.file;
    //   if (doc.title == "mockTitle1") {
    //     expect(doc.distance, 70);
    //     expect(doc.certainty, 59);
    //   } else if (doc.title == "mockTitle2") {
    //     expect(doc.distance, 60);
    //     expect(doc.certainty, 49);
    //   } else if (doc.title == "mockTitle3") {
    //     expect(doc.distance, 50);
    //     expect(doc.certainty, 39);
    //   }
    // }
    // Test deletion of document from the view
    await tester.tap(find.byKey(const Key("delBtn_mockId1")));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));


  });
}