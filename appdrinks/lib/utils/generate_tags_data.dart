import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();
const apiKey = '9973533';
const baseUrl = 'https://www.thecocktaildb.com/api/json/v2';

void main() async {
  try {
    final Set<String> allTags = {};

    // Coleta tags
    for (var letter in 'abcdefghijklmnopqrstuvwxyz'.split('')) {
      final url = '$baseUrl/$apiKey/search.php?f=$letter';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['drinks'] != null) {
          for (var drink in data['drinks']) {
            if (drink['strTags'] != null) {
              final tags = drink['strTags'].toString().split(',');
              allTags.addAll(tags.map((tag) => tag.trim()));
            }
          }
        }
      }
      await Future.delayed(Duration(milliseconds: 500));
    }

    // Cria pasta para tags se não existir
    await Directory('assets/tags').create(recursive: true);

    // Salva tags em arquivo
    final file = File('assets/tags/all_tags.txt');
    await file.writeAsString(allTags.join('\n'));

    logger.i('✅ ${allTags.length} tags salvas em all_tags.txt');
  } catch (e) {
    logger.e('❌ Erro: $e');
  }
}
