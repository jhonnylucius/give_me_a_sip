import 'package:app_netdrinks/controller/search_controller.dart' as netdrink;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final controller = Get.put(netdrink.SearchController(
    Get.find(),
    Get.find(),
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'search_screen.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Get.toNamed('/home'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Botão para busca por ingredientes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed('/ingredient-search'),
              icon: const Icon(Icons.local_bar),
              label: Text(FlutterI18n.translate(
                context,
                'search.search_by_ingredients',
              )),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    FlutterI18n.translate(context, 'search.or_choose_option'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),

          // Botões de filtro em coluna
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _SearchButtonWidget(
                  onPressed: () => controller.searchPopular(),
                  label: FlutterI18n.translate(
                      context, 'search_screen.popular_drinks'),
                ),
                const SizedBox(height: 8),
                _SearchButtonWidget(
                  onPressed: () => controller.searchMaisRecentes(),
                  label: FlutterI18n.translate(
                      context, 'search_screen.recent_drinks'),
                ),
                const SizedBox(height: 8),
                _SearchButtonWidget(
                  onPressed: () => controller.searchNoAlcool(),
                  label: FlutterI18n.translate(
                      context, 'search_screen.non_alcoholic_drinks'),
                ),
                const SizedBox(height: 8),
                _SearchButtonWidget(
                  onPressed: () => controller.searchDezAleatorio(),
                  label: FlutterI18n.translate(
                      context, 'search_screen.random_drinks'),
                ),
              ],
            ),
          ),
          // Contador de resultados
          Obx(() {
            final results = controller.getCurrentResults();
            if (results.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${results.length} ${FlutterI18n.translate(context, 'search.drinks_found')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),

          // Lista de resultados
          Expanded(
            child: Obx(
              () {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = controller.getCurrentResults();

                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      FlutterI18n.translate(
                          context, 'search_screen.no_results'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final cocktail = results[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        elevation: 0, // Remove a sombra
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              cocktail.strDrinkThumb ?? '',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          title: Text(cocktail.strDrink ?? ''),
                          onTap: () =>
                              controller.fetchCocktailDetailsAndNavigate(
                            cocktail.idDrink,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Atualizar o estilo do botão de pesquisa
class _SearchButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _SearchButtonWidget({
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
