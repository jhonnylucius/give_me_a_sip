import 'package:flutter/material.dart';

class SearchDialog extends StatelessWidget {
  final String initialText;

  const SearchDialog({super.key, this.initialText = ''});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: initialText);

    return AlertDialog(
      title: Text('Pesquisar'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Digite sua pesquisa',
        ),
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: (text) {
          Navigator.of(context).pop(text);
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Pesquisar'),
          onPressed: () {
            Navigator.of(context).pop(controller.text);
          },
        ),
      ],
    );
  }
}
