import 'package:app/screens/file_overview_home.dart';
import 'package:flutter/material.dart';

void main() {
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


