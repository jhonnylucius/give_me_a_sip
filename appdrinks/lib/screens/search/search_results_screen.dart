import 'package:app_netdrinks/controller/search_controller_local.dart'
    as custom;
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/widgets/cocktail_fill_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SearchResultsScreen extends StatelessWidget {
  final custom.SearchControllerLocal controller = Get.find();

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
          return const Center(child: CocktailFillLoading());
        }

        final results = controller.currentSearchType.value ==
                custom.SearchTypeLocal.ingredients
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
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.80,
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
          final controller = Get.find<custom.SearchControllerLocal>();
          try {
            final detailsResponse = controller.getById(cocktail.idDrink);
            if (detailsResponse != null) {
              Get.toNamed('/cocktail-detail', arguments: detailsResponse);
            }
          } catch (e) {
            Logger().e('Erro ao buscar detalhes: $e');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 8,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  cocktail.getDrinkImageUrl(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.no_drinks, color: Colors.redAccent),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
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
          ],
        ),
      ),
    );
  }
}
