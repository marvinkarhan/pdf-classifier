import 'package:flutter/material.dart';

class CreateCategoryDialog extends StatefulWidget {
  final ValueChanged<String> onCreateCategory;

  const CreateCategoryDialog({super.key, required this.onCreateCategory});

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final TextEditingController _createCategoryTextFieldController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a category'),
      key: const Key("createCatDialog"),
      content: TextField(
        key: const Key("newCatTitleTextField"),
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
          key: const Key("createCatSaveBtn"),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          child: const Text('create'),
          onPressed: () {
            widget.onCreateCategory(_createCategoryTextFieldController.text);
            _createCategoryTextFieldController.clear();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
