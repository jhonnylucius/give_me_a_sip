import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TranslationService extends GetxService {
  Map<String, String> en = {};
  Map<String, String> pt = {};
  Map<String, String> es = {};

  Future<TranslationService> init() async {
    // Carregar arquivos de tradução
    final enJson = await rootBundle.loadString('assets/lang/en.json');
    final ptJson = await rootBundle.loadString('assets/lang/pt.json');
    final esJson = await rootBundle.loadString('assets/lang/es.json');

    en = Map<String, String>.from(json.decode(enJson));
    pt = Map<String, String>.from(json.decode(ptJson));
    es = Map<String, String>.from(json.decode(esJson));

    return this;
  }

  String translate(String key, {String? locale}) {
    locale ??= Get.locale?.languageCode;

    switch (locale) {
      case 'pt':
        return pt[key] ?? key;
      case 'es':
        return es[key] ?? key;
      default:
        return en[key] ?? key;
    }
  }
}
