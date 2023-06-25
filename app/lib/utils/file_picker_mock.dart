import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:mockito/mockito.dart';

class FilePickerMock extends Mock implements FilePicker {
  FilePickerMock();

  @override
  Future<FilePickerResult> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
  }) async {
    // Create mock files here and return as part of a FilePickerResult
    List<PlatformFile> mockFiles = [];

    PlatformFile file = PlatformFile(
      name: 'test.pdf',
      bytes: Uint8List(0),
      size: 0,
      readStream: null,
    );

    mockFiles.add(file);

    return FilePickerResult(mockFiles);
  }
}
