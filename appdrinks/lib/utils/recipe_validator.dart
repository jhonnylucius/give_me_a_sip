import 'package:logger/logger.dart';

class RecipeValidator {
  static final logger = Logger();

  static bool compareIngredients(
      List<Map<String, String>> recipe1, List<Map<String, String>> recipe2) {
    logger.d('🔍 Iniciando comparação de ingredientes');
    logger.d('📝 Recipe1 (${recipe1.length} ingredientes): $recipe1');
    logger.d('📝 Recipe2 (${recipe2.length} ingredientes): $recipe2');

    if (recipe1.isEmpty || recipe2.isEmpty) {
      logger.d('❌ Uma das receitas está vazia');
      return false;
    }

    if (recipe1.length != recipe2.length) {
      logger.d(
          '❌ Número diferente de ingredientes: ${recipe1.length} vs ${recipe2.length}');
      return false;
    }

    for (var ing1 in recipe1) {
      final name1 = _normalizeIngredient(ing1['name'] ?? '');
      final measure1 = ing1['measure'] ?? '';

      logger.d('🔎 Procurando correspondência para: $name1 ($measure1)');

      try {
        final match = recipe2.firstWhere(
          (ing2) => _normalizeIngredient(ing2['name'] ?? '') == name1,
          orElse: () => {},
        );

        if (match.isEmpty) {
          logger.d('❌ Ingrediente não encontrado: $name1');
          return false;
        }

        final measure2 = match['measure'] ?? '';
        logger.d('📊 Comparando medidas: $measure1 vs $measure2');

        if (measure1 != measure2) {
          logger.d('❌ Medidas diferentes para $name1');
          return false;
        }
      } catch (e) {
        logger.e('❌ Erro ao comparar ingrediente: $e');
        return false;
      }
    }

    logger.d('✅ Receitas são idênticas!');
    return true;
  }

  static String _normalizeIngredient(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }
}
