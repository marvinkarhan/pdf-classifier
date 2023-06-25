import 'package:app/api/backed_service_mock.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';

import '../api/backend_service_impl.dart';
import '../api/i_backend_service.dart';
import 'file_picker_mock.dart';

GetIt sl = GetIt.instance;

void setupSl() {
  sl.registerSingleton<BackendService>(BackendServiceImpl());
  sl.registerSingleton<FilePicker>(FilePicker.platform);
}

void setupSlMock() {
  sl.registerSingleton<BackendService>(BackendServiceMock());
  sl.registerSingleton<FilePicker>(FilePickerMock());
}
