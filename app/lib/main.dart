import 'dart:developer';

import 'package:app/screens/file_overview_home.dart';
import 'package:app/screens/pdf_viewer.dart';
import 'package:app/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:app/model/Config.dart';

void main(List<String> args) async {
  const env = String.fromEnvironment('env');
  WidgetsFlutterBinding.ensureInitialized();
  await setup(env);
  runApp(const MyApp());
}

Future<void> setup(String? env) async {
  // Setup API from env file
  final config = Config();
  await config.loadForEnv(env);
  // Setup ServiceLocator for dependency injection
  setupSl();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Document Classifier',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const FileOverviewHomeScreen(),
          '/pdf': (context) => const PDFViewer(),
        });
  }
}
