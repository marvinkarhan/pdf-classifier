import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileOverviewHomeScreen extends StatefulWidget {
  const FileOverviewHomeScreen({super.key, required this.title});

  final String title;

  @override
  State<FileOverviewHomeScreen> createState() => _FileOverviewHomeScreenState();
}

class _FileOverviewHomeScreenState extends State<FileOverviewHomeScreen> {
  final List<PlatformFile> _overallPickedFiles = [];

  void pickFiles() async {
    final pickedFiles = await FilePicker.platform.pickFiles(
        allowMultiple: true);
    if (pickedFiles == null) {
      return;
    }
    _overallPickedFiles.addAll(pickedFiles.files);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _overallPickedFiles.length,
        itemBuilder: (BuildContext ctxt, int index) => _buildDynamicFileList(ctxt, index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickFiles,
        tooltip: 'Pick files to add',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDynamicFileList(BuildContext ctxt, int index) {
    return Text(_overallPickedFiles[index].name);
  }
}