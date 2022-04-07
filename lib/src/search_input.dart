import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_location_picker/generated/l10n.dart';

/// Custom Search input field, showing the search and clear icons.
class SearchInput extends StatefulWidget {
  const SearchInput(
    this.onSearchInput, {
    Key? key,
        this.searchInputKey,
    this.boxDecoration,
    this.hintText,
  }) : super(key: key);

  final ValueChanged<String> onSearchInput;
  final Key? searchInputKey;
  final BoxDecoration? boxDecoration;
  final String? hintText;

  @override
  State<StatefulWidget> createState() => SearchInputState();
}

class SearchInputState extends State<SearchInput> {
  TextEditingController editController = TextEditingController();

  Timer? debouncer;

  bool hasSearchEntry = false;

  @override
  void initState() {
    super.initState();
    editController.addListener(onSearchInputChange);
  }

  @override
  void dispose() {
    editController.removeListener(onSearchInputChange);
    editController.dispose();

    super.dispose();
  }

  void onSearchInputChange() {
    if (editController.text.isEmpty) {
      debouncer?.cancel();
      widget.onSearchInput(editController.text);
      return;
    }

    if (debouncer?.isActive ?? false) {
      debouncer?.cancel();
    }

    debouncer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchInput(editController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.boxDecoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Colors.white,
          ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: editController,
              decoration: InputDecoration(
                hintText: widget.hintText ??
                    S.of(context).search_place,
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  hasSearchEntry = value.isNotEmpty;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          hasSearchEntry
              ? GestureDetector(
                  child: const Icon(Icons.clear),
                  onTap: () {
                    editController.clear();
                    setState(() {
                      hasSearchEntry = false;
                    });
                  },
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
