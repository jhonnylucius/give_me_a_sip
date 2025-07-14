import 'package:app_netdrinks/controller/search_controller_local.dart'
    as netdrink;
import 'package:app_netdrinks/widgets/cocktail_fill_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final controller = Get.put(netdrink.SearchControllerLocal(
    Get.find(),
    Get.find(),
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText:
                      FlutterI18n.translate(context, 'search.search_by_letter'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                maxLength: 1,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 14),
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    controller.searchByFirstLetter(value.toLowerCase());
                    FocusScope.of(context).unfocus();
                  }
                },
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
            ),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
            SizedBox(
              height: MediaQuery.of(context).size.height - 400,
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(child: CocktailFillLoading());
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
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 200),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final cocktail = results[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () async {
                            final controller =
                                Get.find<netdrink.SearchControllerLocal>();
                            try {
                              final detailsResponse =
                                  controller.getById(cocktail.idDrink);
                              if (detailsResponse != null) {
                                Get.toNamed('/cocktail-detail',
                                    arguments: detailsResponse);
                              }
                            } catch (e) {
                              Logger().e('Erro ao buscar detalhes: $e');
                            }
                          },
                          child: Card(
                            elevation: 0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SizedBox(
                              height: 100, // Altura total do card
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Image.asset(
                                        'assets/data/images/drinks/${cocktail.idDrink}.webp',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      cocktail.strDrink,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}

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
