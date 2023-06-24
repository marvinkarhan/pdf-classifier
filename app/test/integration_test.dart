import 'package:app/main.dart';
import 'package:app/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    setupSlMock(); // register mock backend service for dependency injection
  });

  testWidgets(
      'Document Classifier Integration Test using mock data from the backend_service_mock',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text("Document Classifier"), findsOneWidget);
    // Check if received and rendered the one category and one file
    expect(find.byType(ListTile), findsNWidgets(2));
    // Check if the add file button is there
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // Check if text search field is there
    expect(find.byType(TextField), findsOneWidget);

    // Test canceling of new category dialog
    await tester.tap(find.byType(SpeedDial));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("createCatBtn")));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("createCatDialog")), findsOneWidget);
    await tester.tap(find.byKey(const Key("createCatCancelBtn")));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("createCatDialog")), findsNothing);

    // Test creation of new category
    await tester.tap(find.byType(SpeedDial));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("createCatBtn")));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("createCatDialog")), findsOneWidget);

    Finder textFieldFinder = find.byKey(const Key("newCatTitleTextField"));
    expect(tester.widget<TextField>(textFieldFinder).controller?.text, "",
        reason: "The text field should be empty");
    await tester.enterText(textFieldFinder, "newMockCatTitle");
    await tester.tap(find.byKey(const Key("createCatSaveBtn")));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(3),
        reason: "An additional category should be visible");

    // Test deletion of the new category from the view
    await tester.drag(
        find.byKey(const Key("mockIdCat3")), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("delCatBtn_mockIdCat3")));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2),
        reason: "The additional category should be deleted");

    // Test querying
    await tester.enterText(find.byType(TextField), "MOCK");
    await tester.pump(const Duration(milliseconds: 600));
    Iterable<ListTile> listWidgets = tester.widgetList(find.byType(ListTile));
    expect(listWidgets.length, 3,
        reason: "The query should list all 3 documents");
    // Check if we have gotten and displayed the queried documents
    final certaintyResults = ["59%", "49%", "39%"];
    var i = 0;
    for (var element in listWidgets) {
      final circleAvatarFinder = find.descendant(
        of: find.byWidget(element),
        matching: find.byType(CircleAvatar),
      );
      expect(circleAvatarFinder, findsOneWidget,
          reason: "Each document should have an avatar");

      final textFinder = find.descendant(
        of: circleAvatarFinder,
        matching: find.byType(Text),
      );
      final Text textWidget = tester.widget(textFinder);

      final String certainty = textWidget.data ?? "";
      expect(certainty, certaintyResults[i],
          reason: "The certainty should be calculated correctly");
      i++;
    }
    // Reset back to initial view
    await tester.enterText(find.byType(TextField), "");
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ListTile), findsNWidgets(2),
        reason:
            "After resetting the search we should see one category and one document");

    // Test deletion of document from the view
    await tester.drag(
        find.byKey(const Key("mockIdFile3")), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("delFileBtn_mockIdFile3")));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(1),
        reason:
            "After the document is deleted we should only have the category left");

    // Test if Error Popup opens
    await tester.enterText(find.byType(TextField), "ERROR");
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AlertDialog), findsOneWidget,
        reason: "After triggering the alert the dialog should have popped up");
  });
}
