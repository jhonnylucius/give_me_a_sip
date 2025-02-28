import 'package:app_netdrinks/components/menu.dart';
import 'package:app_netdrinks/controller/iba_list_controller.dart';
import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/models/drink_likes.dart';
import 'package:app_netdrinks/models/iba_drinks.dart';
import 'package:app_netdrinks/screens/iba_cocktail_detail_screen.dart';
import 'package:app_netdrinks/widgets/cocktail_fill_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class IBADrinksScreen extends StatefulWidget {
  final User user;
  const IBADrinksScreen({super.key, required this.user});

  @override
  IBADrinksScreenState createState() => IBADrinksScreenState();
}

class IBADrinksScreenState extends State<IBADrinksScreen> {
  late final IBAListController controller;
  late final LikesController likesController;
  final logger = Logger();
  String selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    controller = Get.find<IBAListController>();
    likesController = Get.find<LikesController>();
    controller.loadIBADrinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(FlutterI18n.translate(context, 'iba_drinks.title')),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/home'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed('/search'),
          ),
        ],
      ),
      drawer: Menu(user: widget.user),
      body: Obx(() {
        final drinks = controller.ibaDrinks;

        if (drinks.isEmpty) {
          return const Center(child: CocktailFillLoading());
        }

        // Modificando a criação da lista de categorias
        final categories = [
          'Todos',
          ...drinks.map((d) => d.category).toSet().toList()..sort()
        ];

        final filteredDrinks = selectedCategory == 'Todos'
            ? drinks
            : drinks.where((d) => d.category == selectedCategory).toList();

        return Column(
          children: [
            // Filtros de Categoria com padding adicional
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 8), // Adicionado horizontal margin
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: isSelected,
                      selectedColor: Colors.redAccent,
                      backgroundColor: Colors.grey[900],
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: category == 'Todos'
                              ? FontWeight.bold
                              : FontWeight.normal, // Destaque para 'Todos'
                        ),
                      ),
                      onSelected: (_) =>
                          setState(() => selectedCategory = category),
                    ),
                  );
                },
              ),
            ),
            // Lista de Drinks
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: filteredDrinks.length,
                itemBuilder: (context, index) {
                  final drink = filteredDrinks[index];
                  return _buildDrinkCard(drink);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDrinkCard(IBADrink drink) {
    return Container(
      height: 490,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => Get.to(() => IBACocktailDetailScreen(drink: drink)),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagem do Drink
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(
                        drink.getDrinkImageUrl(),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Botões de Like e Vídeo
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          // Botão de Vídeo
                          if (drink.videoUrl != null &&
                              drink.videoUrl!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withAlpha((0.5 * 255).toInt()),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () async {
                                  final url = Uri.parse(drink.videoUrl!);
                                  try {
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  } catch (e) {
                                    logger.e('Erro ao abrir vídeo: $e');
                                  }
                                },
                              ),
                            ),
                          // Botão de Like
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: StreamBuilder<DrinkLikes>(
                              stream:
                                  likesController.getLikesStream(drink.idDrink),
                              builder: (context, snapshot) {
                                return IconButton(
                                  icon: Icon(
                                    likesController.isLikedRx(drink.idDrink)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  onPressed: () =>
                                      likesController.toggleLike(drink.idDrink),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Nome do Drink
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Text(
                  drink.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
