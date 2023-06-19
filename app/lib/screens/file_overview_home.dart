import 'dart:developer';

import 'package:app/api/i_backend_service.dart';
import 'package:app/model/Category.dart';
import 'package:app/model/Document.dart';
import 'package:app/screens/pdf_viewer.dart';
import 'package:app/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get_it/get_it.dart';
import 'package:app/utils/service_locator.dart';
import 'dart:async';

class FileOverviewHomeScreen extends StatefulWidget {
  const FileOverviewHomeScreen({super.key});

  @override
  State<FileOverviewHomeScreen> createState() => _FileOverviewHomeScreenState();
}

class _FileOverviewHomeScreenState extends State<FileOverviewHomeScreen> {
  final List<Document> _files = [];
  List<Document> _visibleFiles = [];
  final List<Category> _categories = [];
  final BackendService backendService = sl.get<BackendService>();
  final List<String> _categoryStack = ["root"];
  List<Category> _selectedCategories = [];
  final TextEditingController _createCategoryTextFieldController =
      TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    reload();
    backendService.setOnError(_showErrorMessage);
  }

  void reload() {
    getDocumentsFromBackend();
    getCategoriesFromBackend();
  }

  void getDocumentsFromBackend([String query = ""]) {
    if (query.isEmpty) {
      _searching = false;
      backendService.getAllDocuments().then((docs) {
        _files.clear();
        _files.addAll(docs);
        setState(() {});
      });
    } else {
      _searching = true;
      backendService.queryDocumentById(query).then((docs) {
        _files.clear();
        _files.addAll(docs);
        setState(() {});
      });
    }
  }

  void getCategoriesFromBackend() {
    backendService.getAllCategories().then((cats) {
      _categories.clear();
      _categories.addAll(cats);
      setSelectedCategory(_categoryStack.last);
      setState(() {});
    });
  }

  void setSelectedCategory(String category) {
    if (_categoryStack.last != category) {
      _categoryStack.add(category);
    }
    _selectedCategories =
        _categories.where((element) => element.parentId == category).toList();
    if (category == "root") {
      // Show all unassigned documents
      _visibleFiles = _files
          .where((file) =>
              !_categories.any((c) => c.fileIds?.contains(file.id) ?? false))
          .toList();
    } else {
      final currentCategory =
          _categories.firstWhere((element) => element.id == category);
      _visibleFiles = _files
          .where((file) => currentCategory.fileIds?.contains(file.id) ?? false)
          .toList();
    }

    setState(() {});
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
          reload();
        }
      });
    }
  }

  void createCategory(String title) async {
    backendService.postCategory(title, _categoryStack.last).then((value) {
      if (value) {
        getCategoriesFromBackend();
      }
    });
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

  Future<void> _showCreateCategoryDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a category'),
          content: TextField(
            controller: _createCategoryTextFieldController,
            decoration: const InputDecoration(hintText: "Category title"),
            autofocus: true,
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('cancel'),
              onPressed: () {
                _createCategoryTextFieldController.clear();
                Navigator.pop(context);
              },
            ),
            OutlinedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: const Text('create'),
              onPressed: () {
                createCategory(_createCategoryTextFieldController.text);
                _createCategoryTextFieldController.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _onDeleteDocument(String id) {
    setState(() {
      _files.removeWhere((element) => element.id == id);
    });
    backendService.deleteResourceById(id).then((value) => reload());
  }

  void _onDeleteCategory(String id) {
    setState(() {
      _categories.removeWhere((element) => element.id == id);
    });
    backendService
        .deleteResourceById(id)
        .then((value) => getCategoriesFromBackend());
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
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        backgroundColor: Colors.blue,
        visible: true,
        spacing: 8,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.picture_as_pdf, color: Colors.blue),
            backgroundColor: Colors.white,
            onTap: pickFiles,
            label: 'Add files',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.blue),
            labelBackgroundColor: Colors.white,
          ),
          SpeedDialChild(
            child: const Icon(Icons.create_new_folder, color: Colors.blue),
            backgroundColor: Colors.white,
            onTap: _showCreateCategoryDialog,
            label: 'Create a category',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.blue),
            labelBackgroundColor: Colors.white,
          ),
        ],
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
            child: _files.isEmpty
                ? ListView(
                    children: [
                      ListTile(
                        title: const Text("No files added"),
                        trailing: const Icon(Icons.add),
                        onTap: pickFiles,
                      ),
                    ],
                  )
                : _searching
                    ? _buildFileList()
                    : _buildCategoryFileList()),
      ],
    );
  }

  Widget _buildFileList() {
    return ListView.separated(
        itemCount: _files.length,
        itemBuilder: (BuildContext ctxt, int index) =>
            _buildFileListTile(_files[index]),
        separatorBuilder: (BuildContext ctxt, int index) => const Divider());
  }

  Widget _buildCategoryFileList() {
    return ListView.separated(
        itemCount: _visibleFiles.length +
            _selectedCategories.length +
            (_categoryStack.last == "root" ? 0 : 1),
        itemBuilder: (BuildContext ctxt, int index) =>
            _buildDynamicCategoryFileList(ctxt, index),
        separatorBuilder: (BuildContext ctxt, int index) => const Divider());
  }

  Widget _buildDynamicCategoryFileList(BuildContext ctxt, int index) {
    // add row to navigate to parent category
    if (_categoryStack.last != "root") {
      if (index == 0) {
        return ListTile(
          title: const Text("Go to parent category"),
          leading: const Icon(Icons.arrow_back),
          onTap: () {
            _categoryStack.removeLast();
            setSelectedCategory(_categoryStack.last);
          },
        );
      }
      index -= 1;
    }
    var isCategory = index < _selectedCategories.length;
    return isCategory
        ? _buildCategoryListTile(_selectedCategories[index])
        : _buildFileListTile(_visibleFiles[index - _selectedCategories.length]);
  }

  Widget _buildFileListTile(Document file) {
    return Slidable(
      key: Key(file.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (context) {
              _onDeleteDocument(file.id);

              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('File: ${file.title} deleted')));
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            key: Key("delFileBtn_${file.id}"),
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

  Widget _buildCategoryListTile(Category category) {
    return Slidable(
      key: Key(category.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (context) {
              _onDeleteCategory(category.id);

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Category: ${category.title} deleted')));
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            key: Key("delCatBtn_${category.id}"),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.folder),
        title: Text(category.title),
        trailing: const Icon(Icons.navigate_next),
        onTap: () => setSelectedCategory(category.id),
      ),
    );
  }
}
