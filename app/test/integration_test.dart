import 'dart:math';

import 'package:app/model/Document.dart';

import 'package:app/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  setUpAll(() {
    setupSlMock(); // register mock backend service for dependency injection
  });

  testWidgets('Document Classifier Integration Test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text("Document Classifier"), findsOneWidget);
    // Check if received and rendered three mock documents
    expect(find.byType(ListTile), findsNWidgets(3));
    // Check if the add file button is there
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // CHeck if text search field is there
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), "MOCK");
    await tester.pump(const Duration(milliseconds: 600));
    Iterable<ListTile> listWidgets = tester.widgetList(find.byType(ListTile));
    expect(listWidgets.length, 3);
    // Check if we have gotten and displayed the queried documents
    final distanceResults = ["70%", "60%", "50%"];
    var i = 0;
    for (var element in listWidgets) {
      final circleAvatarFinder = find.descendant(
        of: find.byWidget(element),
        matching: find.byType(CircleAvatar),
      );
      expect(circleAvatarFinder, findsOneWidget);

      final textFinder = find.descendant(
        of: circleAvatarFinder,
        matching: find.byType(Text),
      );
      final Text textWidget = tester.widget(textFinder);

      final String certainty = textWidget.data ?? "";
      expect(certainty, distanceResults[i]);
      i++;
    }
    // Test deletion of document from the view
    await tester.tap(find.byKey(const Key("delBtn_mockId1")));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
