import 'dart:convert';

import 'package:flutter/services.dart';

class Config {
  Config._privateConstructor();
  static final Config _config = Config._privateConstructor();
  String? backendUrl;

  factory Config() {
    return _config;
  }

  Future<void> loadForEnv(String? env) async {
    if (env == '') env = null;
    env = env ?? "dev";
    final fileContent = await rootBundle.loadString(
      "assets/config/$env.json",
    );
    final json = jsonDecode(fileContent);
    backendUrl = json["backendUrl"];
  }
}
