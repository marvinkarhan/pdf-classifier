import 'package:get_it/get_it.dart';
import '../api/backend_service_impl.dart';
import '../api/i_backend_service.dart';

GetIt sl = GetIt.instance;

void setupSl() {
  sl.registerSingleton<BackendService>(BackendServiceImpl());
}
