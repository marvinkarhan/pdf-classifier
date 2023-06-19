import 'package:app/model/Document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FileListTile extends StatelessWidget {
  final Document file;
  final Function() onFileDelete;
  final Function() onFileOpen;

  const FileListTile({
    Key? key,
    required this.file,
    required this.onFileDelete,
    required this.onFileOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(file.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (context) {
              onFileDelete();
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
        onTap: onFileOpen,
      ),
    );
  }
}
