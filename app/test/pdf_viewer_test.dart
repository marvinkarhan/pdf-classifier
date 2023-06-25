import 'package:app/main.dart';
import 'package:app/screens/file_category_overview.dart';
import 'package:app/screens/pdf_viewer.dart';
import 'package:app/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'http_interceptor.dart';

void main() {
  setUpAll(() async {
    setupSlMock(); // register mock backend service for dependency injection
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
    mockApis();
  });

  testWidgets('PDFViewer should load document and display it',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(2));
    // Find the mockFileTitle1 document in the list
    expect(find.byKey(const Key("mockIdFile3")), findsOneWidget);
    await tester.tap(find.byKey(const Key("mockIdFile3")));
    // await the navigation and the async loading of the PDF
    await tester.pump(const Duration(seconds: 1));
    // trigger rerender
    await tester.pump();

    // Verify the PDF is loaded and displayed
    expect(find.byType(SfPdfViewer), findsOneWidget);

    // navigate back to the file overview
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2),
        reason: "The root directory should contain 2 elements");
    await tester.pumpAndSettle();
  });
}
