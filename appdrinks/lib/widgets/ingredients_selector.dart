import 'package:app_netdrinks/services/translation_service.dart';
import 'package:app_netdrinks/utils/string_normalizer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IngredientsSelector extends StatelessWidget {
  final List<String> selectedIngredients;
  final Function(List<String>, [bool]) onIngredientsChanged;
  final String searchQuery;

  const IngredientsSelector({
    super.key,
    required this.selectedIngredients,
    required this.onIngredientsChanged,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final translationService = Get.find<TranslationService>();
    final currentLang = translationService.currentLanguage;
    final ingredients = translationService.ingredientsData;

    final displayIngredients = searchQuery.isEmpty
        ? ingredients.keys.toList()
        : ingredients.entries
            .where((entry) => entry.value[currentLang]
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .map((e) => e.key)
            .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: displayIngredients.length,
      itemBuilder: (context, index) {
        final ingredient = displayIngredients[index];
        return Obx(() {
          final isSelected = selectedIngredients.contains(ingredient);

          return Card(
            elevation: isSelected ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isSelected
                  ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: () {
                var newSelection = List<String>.from(selectedIngredients);
                if (isSelected) {
                  newSelection.remove(ingredient);
                } else {
                  newSelection.add(ingredient);
                }
                onIngredientsChanged(newSelection, false);
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          IngredientImageMapper.getImagePath(ingredient) ??
                              'assets/data/images/ingredients/default.webp',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.local_bar,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          ingredients[ingredient][currentLang],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
