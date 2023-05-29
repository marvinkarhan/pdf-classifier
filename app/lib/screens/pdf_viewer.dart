import 'dart:io';
import 'package:app/api/i_backend_service.dart';
import 'package:app/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PDFViewer extends StatefulWidget {
  final String id;
  const PDFViewer({super.key, required this.id});

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  String pathPDF = "";
  final BackendService backendService = sl.get<BackendService>();

  @override
  void initState() {
    super.initState();
    downloadFile();
  }

  Future<void> downloadFile() async {
    backendService
        .downloadDocumentById(widget.id)
        .then((path) => setState(() => pathPDF = path));
  }

  @override
  Widget build(BuildContext context) {
    if (pathPDF == "") {
      return Center(child: CircularProgressIndicator());
    } else {
      return PDFView(
        filePath: pathPDF,
        autoSpacing: true,
        pageSnap: true,
        fitEachPage: true,
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
      );
    }
  }
}
