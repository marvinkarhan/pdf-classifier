import 'dart:developer';

import 'package:app/api/i_backend_service.dart';
import 'package:app/model/Category.dart';
import 'package:app/model/Document.dart';
import 'package:app/screens/pdf_viewer.dart';
import 'package:app/widgets/category_list_tile_widget.dart';
import 'package:app/widgets/file_category_speed_dial_widget.dart';
import 'package:app/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get_it/get_it.dart';
import 'package:app/utils/service_locator.dart';
import 'dart:async';

import '../widgets/create_category_dialog_widget.dart';
import '../widgets/file_list_tile_widget.dart';

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
      builder: (context) => CreateCategoryDialog(
        onCreateCategory: createCategory,
      ),
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
      floatingActionButton: FileCategorySpeedDial(
          onPickFiles: pickFiles, onCreateCategory: _showCreateCategoryDialog),
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
        itemBuilder: (BuildContext ctxt, int index) => FileListTile(
            file: _files[index],
            onFileDelete: () => _onDeleteDocument(_files[index].id),
            onFileOpen: () => _openFile(_files[index].id)),
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
    if (isCategory) {
      var category = _selectedCategories[index];
      return CategoryListTile(
          category: category,
          onCategoryDelete: () => _onDeleteCategory(category.id),
          onCategorySelect: () => setSelectedCategory(category.id));
    } else {
      var file = _visibleFiles[index - _selectedCategories.length];
      return FileListTile(
          file: file,
          onFileDelete: () => _onDeleteDocument(file.id),
          onFileOpen: () => _openFile(file.id));
    }
  }
}
