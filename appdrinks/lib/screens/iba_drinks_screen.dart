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
import 'package:shared_preferences/shared_preferences.dart';
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
  final RxInt _viewType = 0.obs; // 0 para lista, 1 para grid

  @override
  void initState() {
    super.initState();
    controller = Get.find<IBAListController>();
    likesController = Get.find<LikesController>();
    controller.loadIBADrinks();
    _loadViewPreference();
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _viewType.value = prefs.getInt('iba_view_type') ?? 0;
  }

  Future<void> _saveViewPreference(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('iba_view_type', value);
    _viewType.value = value;
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
          PopupMenuButton<int>(
            icon: const Icon(Icons.view_agenda),
            onSelected: _saveViewPreference,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.view_agenda,
                        color: _viewType.value == 0 ? Colors.red : Colors.grey),
                    const SizedBox(width: 8),
                    Text(FlutterI18n.translate(context, 'view.list')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.grid_view,
                        color: _viewType.value == 1 ? Colors.red : Colors.grey),
                    const SizedBox(width: 8),
                    Text(FlutterI18n.translate(context, 'view.grid')),
                  ],
                ),
              ),
            ],
          ),
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

        final categories = [
          'Todos',
          ...drinks.map((d) => d.category).toSet().toList()..sort()
        ];

        final filteredDrinks = selectedCategory == 'Todos'
            ? drinks
            : drinks.where((d) => d.category == selectedCategory).toList();

        return Column(
          children: [
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                              : FontWeight.normal,
                        ),
                      ),
                      onSelected: (_) =>
                          setState(() => selectedCategory = category),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Obx(() => _viewType.value == 0
                  ? _buildListView(filteredDrinks)
                  : _buildGridView(filteredDrinks)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildListView(List<IBADrink> drinks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: drinks.length,
      itemBuilder: (context, index) {
        return _buildDrinkCard(drinks[index]);
      },
    );
  }

  Widget _buildGridView(List<IBADrink> drinks) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: drinks.length,
      itemBuilder: (context, index) {
        final drink = drinks[index];
        return GestureDetector(
          onTap: () => Get.to(() => IBACocktailDetailScreen(drink: drink)),
          child: Card(
            elevation: 4,
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
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.asset(
                          drink.getDrinkImageUrl(),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (drink.videoUrl != null &&
                                drink.videoUrl!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(128),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  iconSize: 20,
                                  icon: const Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
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
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(128),
                                shape: BoxShape.circle,
                              ),
                              child: StreamBuilder<DrinkLikes>(
                                stream: likesController
                                    .getLikesStream(drink.idDrink),
                                builder: (context, snapshot) {
                                  return IconButton(
                                    iconSize: 20,
                                    icon: Icon(
                                      likesController.isLikedRx(drink.idDrink)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => likesController
                                        .toggleLike(drink.idDrink),
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
                Container(
                  padding: const EdgeInsets.all(8),
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(
                        drink.getDrinkImageUrl(),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
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
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  Colors.black.withAlpha((0.5 * 255).toInt()),
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
