import 'package:app_netdrinks/controller/search_controller.dart' as custom;
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';

class SearchResultsScreen extends StatelessWidget {
  final custom.SearchController controller = Get.find();

  SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'search.results_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final results =
            controller.currentSearchType.value == custom.SearchType.ingredients
                ? controller.multiIngredientsResults
                : controller.searchResults;

        if (results.isEmpty) {
          return Center(
            child: Text(
              FlutterI18n.translate(context, 'search.no_results'),
              style: const TextStyle(fontSize: 18),
            ),
          );
        }

        return Column(
          children: [
            // Contador de resultados
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${results.length} ${FlutterI18n.translate(context, 'search.drinks_found')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Grid de resultados
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final cocktail = results[index];
                  return CocktailCard(cocktail: cocktail, user: '');
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class CocktailCard extends StatelessWidget {
  final Cocktail cocktail;
  final String user;

  const CocktailCard({
    required this.cocktail,
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () async {
          final controller = Get.find<custom.SearchController>();
          await controller.fetchCocktailDetailsAndNavigate(cocktail.idDrink);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do drink (mantém o mesmo)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 165,
                width: double.infinity,
                child: Image.network(
                  cocktail.strDrinkThumb ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.no_drinks, color: Colors.redAccent),
                  ),
                ),
              ),
            ),
            // Nome do drink (mantém o mesmo)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cocktail.strDrink,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            // Tags (nova adição)
            if (cocktail.strTags?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: cocktail.strTags!
                      .split(',')
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag.trim(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 8), // Espaçamento final
          ],
        ),
      ),
    );
  }
}
