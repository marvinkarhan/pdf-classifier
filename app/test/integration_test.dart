import 'dart:math';

import 'package:app/model/Document.dart';

import 'package:app/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
    // Check if received and rendered the one category and one file
    expect(find.byType(ListTile), findsNWidgets(2));
    // Check if the add file button is there
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // CHeck if text search field is there
    expect(find.byType(TextField), findsOneWidget);

    // Test creation of new category
    await tester.tap(find.byType(SpeedDial));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("createCatBtn")));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("createCatDialog")), findsOneWidget);
    await tester.enterText(find.byKey(const Key("newCatTitleTextField")), "newMockCatTitle");
    await tester.tap(find.byKey(const Key("createCatSaveBtn")));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(3));

    // Test querying
    Iterable<ListTile> listWid3gets = tester.widgetList(find.byType(ListTile));
    await tester.enterText(find.byType(TextField), "MOCK");
    await tester.pump(const Duration(milliseconds: 600));
    Iterable<ListTile> listWidgets = tester.widgetList(find.byType(ListTile));
    expect(listWidgets.length, 3);
    // Check if we have gotten and displayed the queried documents
    final certaintyResults = ["59%", "49%", "39%"];
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
      expect(certainty, certaintyResults[i]);
      i++;
    }
    // Reset back to initial view
    await tester.enterText(find.byType(TextField), "");
    await tester.pump(const Duration(milliseconds: 600));

    // Test deletion of document from the view
    await tester.drag(find.byKey(const Key("mockIdFile3")), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("delFileBtn_mockIdFile3")));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));


    // Test if Error Popup opens
    await tester.enterText(find.byType(TextField), "ERROR");
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
