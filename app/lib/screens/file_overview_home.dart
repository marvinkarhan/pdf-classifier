import 'package:app/api/i_backend_service.dart';
import 'package:app/model/Document.dart';
import 'package:app/screens/pdf_viewer.dart';
import 'package:app/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:app/utils/service_locator.dart';
import 'dart:async';

class FileOverviewHomeScreen extends StatefulWidget {
  const FileOverviewHomeScreen({super.key});

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

  void getDocumentsFromBackend([String query = ""]) {
    if (query.isEmpty) {
      backendService.getAllDocuments().then((docs) {
        _overallPickedFiles.clear();
        _overallPickedFiles.addAll(docs);
        setState(() {});
      });
    } else {
      backendService.queryDocumentById(query).then((docs) {
        _overallPickedFiles.clear();
        _overallPickedFiles.addAll(docs);
        setState(() {});
      });
    }
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
    setState(() {
      _overallPickedFiles.removeWhere((element) => element.id == id);
    });
    backendService.deleteDocumentById(id);
    getDocumentsFromBackend();
  }

  void _openFile(String id) {
    Navigator.pushNamed(context, '/pdf', arguments: {'id': id});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Classifier"),
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
    return Column(
      children: <Widget>[
        Search(
          onSearch: getDocumentsFromBackend,
        ),
        Expanded(
            child: _overallPickedFiles.isEmpty
                ? ListView(
                    children: [
                      ListTile(
                        title: const Text("No files added"),
                        trailing: const Icon(Icons.add),
                        onTap: pickFiles,
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: _overallPickedFiles.length,
                    itemBuilder: (BuildContext ctxt, int index) =>
                        _buildDynamicFileList(ctxt, index),
                    separatorBuilder: (BuildContext ctxt, int index) =>
                        const Divider())),
      ],
    );
  }

  Widget _buildDynamicFileList(BuildContext ctxt, int index) {
    var file = _overallPickedFiles[index];
    return Slidable(
      key: Key(file.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (context) {
              _onDeleteCard(file.id);

              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${file.title} deleted')));
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: file.certainty != null
            ? CircleAvatar(
                backgroundColor:
                    Color.lerp(Colors.red, Colors.green, file.certainty!),
                child: Text(
                  '${(file.certainty! * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : const Icon(Icons.picture_as_pdf),
        title: Text(file.title),
        onTap: () => _openFile(file.id),
      ),
    );
  }
}
