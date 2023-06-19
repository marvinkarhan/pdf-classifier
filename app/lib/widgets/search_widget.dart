import 'dart:async';

import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const Search({super.key, required this.onSearch});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 12.0),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: const InputDecoration(
          labelText: "Search",
          hintText: "Search",
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
