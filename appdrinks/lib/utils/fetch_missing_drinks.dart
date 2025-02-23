import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:translator/translator.dart';

final logger = Logger();
const apiKey = '9973533';
const baseUrl = 'https://www.thecocktaildb.com/api/json/v2';

Future<void> main() async {
  final missingDrinkIds = [
    '13581',
    '13899',
    '13940',
    '14029',
    '14229',
    '14588',
    '14598',
    '15288',
    '15300',
    '16108',
    '17060',
    '17105',
    '178318',
    '15346'
  ];

  try {
    final Map<String, dynamic> finalData = {"drinks": {}, "ingredients": {}};

    await _createDirectories();

    for (var id in missingDrinkIds) {
      final url = '$baseUrl/$apiKey/lookup.php?i=$id';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['drinks'] != null && data['drinks'].isNotEmpty) {
          await _processDrink(data['drinks'][0], finalData);
          logger.i('Drink $id processado com sucesso');
        }
      }
      await Future.delayed(Duration(milliseconds: 500));
    }

    final encoder = JsonEncoder.withIndent('  ');
    await File('lib/data/missing_drinks_data.json')
        .writeAsString(encoder.convert(finalData));

    logger.i('Drinks faltantes salvos com sucesso!');
  } catch (e) {
    logger.e('Erro: $e');
  }
}

Future<void> _createDirectories() async {
  final dirs = [
    'lib/data',
    'lib/data/images/drinks',
    'lib/data/images/ingredients'
  ];

  for (var dir in dirs) {
    final directory = Directory(dir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
}

Future<void> _processDrink(
    Map<String, dynamic> drink, Map<String, dynamic> finalData) async {
  final id = drink['idDrink'];
  final ingredients = [];

  for (var i = 1; i <= 15; i++) {
    final ingredient = drink['strIngredient$i'];
    final measure = drink['strMeasure$i'];

    if (ingredient != null && ingredient.toString().isNotEmpty) {
      ingredients.add({
        "name": ingredient,
        "measure": measure ?? "to taste",
        "imageUrl":
            "ingredients/${ingredient.toLowerCase().replaceAll(' ', '_')}.png"
      });

      if (!finalData["ingredients"].containsKey(ingredient.toLowerCase())) {
        finalData["ingredients"][ingredient.toLowerCase()] = {
          "names": [ingredient],
          "image":
              "ingredients/${ingredient.toLowerCase().replaceAll(' ', '_')}.png",
          "translations": await _translateIngredient(ingredient)
        };
      }

      await _downloadIngredientImage(ingredient);
    }
  }

  final translations =
      await _translateInstructions(drink['strInstructions'] ?? '');

  finalData["drinks"][id] = {
    "id": id,
    "name": drink['strDrink'],
    "category": drink['strCategory'],
    "alcoholic": drink['strAlcoholic'],
    "glass": drink['strGlass'],
    "instructions": translations,
    "ingredients": ingredients,
    "tags": drink['strTags']?.split(',').map((tag) => tag.trim()).toList() ?? []
  };

  await _downloadDrinkImage(id, drink['strDrinkThumb']);
}

Future<Map<String, String>> _translateIngredient(String ingredient) async {
  final translator = GoogleTranslator();
  final translations = <String, String>{};

  for (var lang in ['pt', 'es', 'fr', 'it', 'de']) {
    try {
      final translation = await translator.translate(
        ingredient,
        from: 'en',
        to: lang,
      );
      translations[lang] = translation.text;
      await Future.delayed(Duration(milliseconds: 200));
    } catch (e) {
      logger.e('Erro ao traduzir ingrediente $ingredient para $lang: $e');
      translations[lang] = ingredient;
    }
  }

  return translations;
}

Future<Map<String, String>> _translateInstructions(String instructions) async {
  final translator = GoogleTranslator();
  final translations = {'en': instructions};

  for (var lang in ['pt', 'es', 'fr', 'it', 'de']) {
    try {
      final translation = await translator.translate(
        instructions,
        from: 'en',
        to: lang,
      );
      translations[lang] = translation.text;
      await Future.delayed(Duration(milliseconds: 200));
    } catch (e) {
      logger.e('Erro ao traduzir instruções para $lang: $e');
      translations[lang] = instructions;
    }
  }

  return translations;
}

Future<void> _downloadIngredientImage(String ingredient) async {
  final fileName =
      'lib/data/images/ingredients/${ingredient.toLowerCase().replaceAll(' ', '_')}.png';
  if (await File(fileName).exists()) return;

  try {
    final url =
        'https://www.thecocktaildb.com/images/ingredients/$ingredient.png';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await File(fileName).writeAsBytes(response.bodyBytes);
      logger.i('Imagem do ingrediente $ingredient baixada com sucesso');
    }
  } catch (e) {
    logger.e('Erro ao baixar imagem do ingrediente $ingredient: $e');
  }
}

Future<void> _downloadDrinkImage(String id, String? url) async {
  if (url == null) return;

  final fileName = 'lib/data/images/drinks/$id.jpg';
  if (await File(fileName).exists()) return;

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await File(fileName).writeAsBytes(response.bodyBytes);
      logger.i('Imagem do drink $id baixada com sucesso');
    }
  } catch (e) {
    logger.e('Erro ao baixar imagem do drink $id: $e');
  }
}
