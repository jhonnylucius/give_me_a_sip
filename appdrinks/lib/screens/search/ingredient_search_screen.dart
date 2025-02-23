import 'package:app_netdrinks/controller/search_controller.dart' as netdrink;
import 'package:app_netdrinks/widgets/ingredients_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';

class IngredientSearchScreen extends StatefulWidget {
  const IngredientSearchScreen({super.key});

  @override
  State<IngredientSearchScreen> createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  final controller = Get.find<netdrink.SearchController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'search.ingredients_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Botão de pesquisa na AppBar
          Obx(() {
            if (controller.selectedIngredients.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                controller.searchMultiIngredients(
                  controller.selectedIngredients.join(','),
                );
                Get.toNamed(
                    '/search-results'); // Navega para tela de resultados
              },
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Ingredientes selecionados
          Obx(() {
            if (controller.selectedIngredientsDisplay.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                children:
                    controller.selectedIngredientsDisplay.map((ingredient) {
                  return Chip(
                    label: Text(ingredient),
                    onDeleted: () {
                      final index = controller.selectedIngredientsDisplay
                          .indexOf(ingredient);
                      if (index != -1) {
                        var newList =
                            List<String>.from(controller.selectedIngredients);
                        newList.removeAt(index);
                        controller.updateSelectedIngredients(newList, false);
                      }
                    },
                  );
                }).toList(),
              ),
            );
          }),

          // Grid de ingredientes
          Expanded(
            child: IngredientsSelector(
              selectedIngredients: controller.selectedIngredients,
              onIngredientsChanged: (ingredients, [search = false]) {
                controller.updateSelectedIngredients(ingredients, false);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
