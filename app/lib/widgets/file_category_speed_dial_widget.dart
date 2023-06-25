import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FileCategorySpeedDial extends StatelessWidget {
  final Function() onPickFiles;
  final Function() onCreateCategory;

  const FileCategorySpeedDial({
    super.key,
    required this.onPickFiles,
    required this.onCreateCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      backgroundColor: Colors.blue,
      visible: true,
      spacing: 8,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.picture_as_pdf, color: Colors.blue),
          backgroundColor: Colors.white,
          onTap: onPickFiles,
          label: 'Add files',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
          labelBackgroundColor: Colors.white,
          key: const Key("addFilesBtn"),
        ),
        SpeedDialChild(
            child: const Icon(Icons.create_new_folder, color: Colors.blue),
            backgroundColor: Colors.white,
            onTap: onCreateCategory,
            label: 'Create a category',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.blue),
            labelBackgroundColor: Colors.white,
            key: const Key("createCatBtn")),
      ],
    );
  }
}
