import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class SearchDialog extends StatelessWidget {
  final String initialText;

  const SearchDialog({super.key, this.initialText = ''});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: initialText);

    return AlertDialog(
      title: Text(FlutterI18n.translate(context, 'search_dialog.title')),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: FlutterI18n.translate(context, 'search_dialog.hint'),
        ),
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: (text) {
          Navigator.of(context).pop(text);
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text(FlutterI18n.translate(context, 'search_dialog.cancel')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(FlutterI18n.translate(context, 'search_dialog.search')),
          onPressed: () {
            Navigator.of(context).pop(controller.text);
          },
        ),
      ],
    );
  }
}
