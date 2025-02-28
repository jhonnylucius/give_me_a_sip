import 'dart:convert';

import 'package:app_netdrinks/models/iba_drinks.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class IBADrinksRepository {
  final logger = Logger();

  Future<IBADrink?> getDrinkById(String drinkId) async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/drinks_data_iba.json');
      final jsonData = json.decode(jsonString);
      final drinksMap = jsonData['drinks'] as Map<String, dynamic>;

      if (drinksMap.containsKey(drinkId)) {
        final drinkData = drinksMap[drinkId];
        return IBADrink.fromJson({...drinkData, 'id': drinkId});
      }
      return null;
    } catch (e) {
      logger.e('Erro ao buscar drink por ID: $e');
      return null;
    }
  }

  Future<List<IBADrink>> loadIBADrinks() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/drinks_data_iba.json');
      final jsonData = json.decode(jsonString);
      final drinksMap = jsonData['drinks'] as Map<String, dynamic>;

      List<IBADrink> drinks = [];
      drinksMap.forEach((id, data) {
        try {
          final Map<String, dynamic> drinkWithId = {
            ...data as Map<String, dynamic>,
            'id': id,
          };
          drinks.add(IBADrink.fromJson(drinkWithId));
        } catch (e) {
          logger.e('Erro ao processar drink $id: $e');
        }
      });

      return drinks;
    } catch (e) {
      logger.e('Erro ao carregar drinks IBA: $e');
      return [];
    }
  }
}
