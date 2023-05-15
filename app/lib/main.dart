import 'package:app/screens/file_overview_home.dart';
import 'package:flutter/material.dart';
import 'package:app/model/Config.dart';

void main({String? env}) async {
  final config = Config();
  await config.loadForEnv(env);
  runApp(const MyApp());
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
      home: const FileOverviewHomeScreen(title: 'Document Classifier Home'),
    );
  }
}


