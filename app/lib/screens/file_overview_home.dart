import 'package:app/api/i_backend_service.dart';
import 'package:app/model/Document.dart';
import 'package:app/screens/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:app/utils/service_locator.dart';
import 'dart:async';

class FileOverviewHomeScreen extends StatefulWidget {
  const FileOverviewHomeScreen({super.key, required this.title});

  final String title;

  @override
  State<FileOverviewHomeScreen> createState() => _FileOverviewHomeScreenState();
}

class _FileOverviewHomeScreenState extends State<FileOverviewHomeScreen> {
  final List<Document> _overallPickedFiles = [];
  final BackendService backendService = sl.get<BackendService>();
  String _showFileId = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    getDocumentsFromBackend();
    backendService.setOnError(_showErrorMessage);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getDocumentsFromBackend(query);
    });
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
    setState(() {
      _showFileId = id;
    });
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
    return _showFileId != ""
        ? PDFViewer(id: _showFileId)
        : Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 12.0),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(width: 3.0, color: Colors.blue),
                    ),
                  ),
                ),
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
        leading: const Icon(Icons.picture_as_pdf),
        title: Text(file.title),
        onTap: () => _openFile(file.id),
      ),
    );
  }
}
