import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hentaiz_viewer/view_models/main_page_view_model.dart';

class SearchAction extends StatefulWidget {
  const SearchAction({super.key});

  @override
  State<SearchAction> createState() => _SearchActionState();
}

class _SearchActionState extends State<SearchAction> {
  bool _showSearchField = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MainPageViewModel>(context, listen: false);

    return Row(
      children: [
        if (_showSearchField)
          SizedBox(
            width: 200,
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search videos...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (value) {
                vm.search(value);
              },
            ),
          ),
        IconButton(
          icon: Icon(_showSearchField ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (_showSearchField) {
                _controller.clear();
                vm.clearSearch();
              }
              _showSearchField = !_showSearchField;
            });
          },
        ),
      ],
    );
  }
}
