import 'package:app/api/i_backend_service.dart';
import 'package:app/model/Document.dart';
import 'package:app/widgets/pdf_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:app/utils/service_locator.dart';

class FileOverviewHomeScreen extends StatefulWidget {
  const FileOverviewHomeScreen({super.key, required this.title});

  final String title;

  @override
  State<FileOverviewHomeScreen> createState() => _FileOverviewHomeScreenState();
}

class _FileOverviewHomeScreenState extends State<FileOverviewHomeScreen> {
  final List<Document> _overallPickedFiles = [];
  final BackendService backendService = sl.get<BackendService>();

  @override
  void initState() {
    super.initState();
    getDocumentsFromBackend();
    backendService.setOnError(_showErrorMessage);
  }

  void getDocumentsFromBackend() {
    backendService.getAllDocuments().then((docs) {
      _overallPickedFiles.clear();
      _overallPickedFiles.addAll(docs);
      setState(() {});
    });
  }

  void pickFiles() async {
    final pickedFiles = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true);
    if (pickedFiles == null) {
      return;
    }

    for (var file in pickedFiles.files) {
      backendService.postDocument(file).then((value) {
        if (value) {
          getDocumentsFromBackend();
        }
      });
    }
  }

  void _showErrorMessage(String errorMessage) {
    final alert = AlertDialog(
      content: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _onDeleteCard(String id) {
    backendService.deleteDocumentById(id);
    getDocumentsFromBackend();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: createBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: pickFiles,
        tooltip: 'Pick files to add',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget createBody() {
    if (_overallPickedFiles.isEmpty) {
      return const Center(child: Text("No files added"));
    } else {
      return ListView.builder(
        itemCount: _overallPickedFiles.length,
        itemBuilder: (BuildContext ctxt, int index) =>
            _buildDynamicFileList(ctxt, index),
      );
    }
  }

  Widget _buildDynamicFileList(BuildContext ctxt, int index) {
    var file = _overallPickedFiles[index];
    return PdfCardWidget(file: file, fileTag: "sampleTag", onDelete: _onDeleteCard,);
  }
}
