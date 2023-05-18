import 'dart:math';

import 'package:flutter/material.dart';

class PdfCardWidget extends StatelessWidget {
  final String fileName;
  final String fileTag;

  const PdfCardWidget(
      {super.key, required this.fileName, required this.fileTag});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              leading: const Icon(Icons.description), title: Text(fileName)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildTagChip(fileTag)],
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
}
