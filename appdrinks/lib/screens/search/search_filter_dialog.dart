import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class SearchFilterDialog extends StatelessWidget {
  final Function(String) onFilterSelected;

  const SearchFilterDialog({super.key, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, 'search_filter_dialog.title')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(FlutterI18n.translate(
                context, 'search_filter_dialog.first_letter')),
            onTap: () => onFilterSelected('firstLetter'),
          ),
          ListTile(
            title: Text(FlutterI18n.translate(
                context, 'search_filter_dialog.category')),
            onTap: () => onFilterSelected('category'),
          ),
          ListTile(
            title: Text(FlutterI18n.translate(
                context, 'search_filter_dialog.ingredient')),
            onTap: () => onFilterSelected('ingredient'),
          ),
          ListTile(
            title: Text(FlutterI18n.translate(
                context, 'search_filter_dialog.alcoholic')),
            onTap: () => onFilterSelected('alcoholic'),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
              FlutterI18n.translate(context, 'search_filter_dialog.cancel')),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
