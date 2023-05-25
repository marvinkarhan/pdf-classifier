import 'dart:math';

import 'package:app/model/Document.dart';
import 'package:flutter/material.dart';

class PdfCardWidget extends StatelessWidget {
  final Document file;
  final String fileTag;
  final Function(String id) onDelete;

  const PdfCardWidget(
      {super.key,
      required this.file,
      required this.fileTag,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(file.title),
            subtitle: (file.certainty != null && file.distance != null)
                ? Text(
                    'Certainty: ${(file.certainty! * 100).toStringAsFixed(2)}, Distance: ${file.distance!.toStringAsFixed(4)}')
                : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTagChip(fileTag), _buildDeleteButton()],
          )
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    var generatedBgColor = Random().nextInt(Colors.primaries.length);
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Chip(
          label: Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.primaries[generatedBgColor],
          elevation: 4.0,
          shadowColor: Colors.grey[60],
          padding: const EdgeInsets.all(2.0),
        ));
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        onDelete.call(file.id);
      },
    );
  }
}
