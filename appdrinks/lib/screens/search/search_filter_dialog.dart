import 'package:flutter/material.dart';

class SearchFilterDialog extends StatelessWidget {
  final Function(String) onFilterSelected;

  const SearchFilterDialog({super.key, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selecione o Filtro de Pesquisa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Buscar por Primeira Letra'),
            onTap: () => onFilterSelected('firstLetter'),
          ),
          ListTile(
            title: Text('Buscar por Categoria'),
            onTap: () => onFilterSelected('category'),
          ),
          ListTile(
            title: Text('Buscar por Ingrediente'),
            onTap: () => onFilterSelected('ingredient'),
          ),
          ListTile(
            title: Text('Buscar por Tipo de Bebida'),
            onTap: () => onFilterSelected('alcoholic'),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
