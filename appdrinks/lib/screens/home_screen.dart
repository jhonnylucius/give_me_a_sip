import 'package:app_netdrinks/components/menu.dart';
import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/enums/recipe_type.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/drink_likes.dart';
import 'package:app_netdrinks/screens/cocktail_detail_screen.dart';
import 'package:app_netdrinks/widgets/cocktail_fill_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final bool showFavorites;

  const HomeScreen({super.key, required this.user, this.showFavorites = false});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late PageController pageController;
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  late final CocktailListController controller;
  late final LikesController likesController;
  final RxInt _viewType = 0.obs;
  double _viewportFraction = 0.7;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CocktailListController>();
    likesController = Get.find<LikesController>();
    _loadViewPreference();
    _initializePageController();
    if (widget.showFavorites) {
      likesController.loadUserLikedDrinks();
    }
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _viewType.value = prefs.getInt('view_type') ?? 0;
  }

  Future<void> _saveViewPreference(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('view_type', value);
    _viewType.value = value;
  }

  void _initializePageController() {
    pageController = PageController(viewportFraction: _viewportFraction);
    pageController.addListener(_onPageChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    final newViewportFraction = screenWidth > 768 ? 0.3 : 0.7;

    if (newViewportFraction != _viewportFraction) {
      _viewportFraction = newViewportFraction;
      pageController.removeListener(_onPageChanged);
      pageController.dispose();
      _initializePageController();
      _currentPage.value = 0;
    }
  }

  void _onPageChanged() {
    int page = pageController.page?.round() ?? 0;
    _currentPage.value = page;
  }

  void _navigateToDetails(Cocktail cocktail) {
    Get.to(() => CocktailDetailScreen(cocktail: cocktail));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(179),
        elevation: 0,
        title: Text(widget.showFavorites
            ? FlutterI18n.translate(context, 'home_screen.favorites')
            : FlutterI18n.translate(context, 'home_screen.title')),
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
                    Icon(Icons.view_carousel,
                        color: _viewType.value == 0 ? Colors.red : Colors.grey),
                    const SizedBox(width: 8),
                    Text(FlutterI18n.translate(context, 'view.carousel')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.view_agenda,
                        color: _viewType.value == 1 ? Colors.red : Colors.grey),
                    const SizedBox(width: 8),
                    Text(FlutterI18n.translate(context, 'view.list')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.grid_view,
                        color: _viewType.value == 2 ? Colors.red : Colors.grey),
                    const SizedBox(width: 8),
                    Text(FlutterI18n.translate(context, 'view.grid')),
                  ],
                ),
              ),
            ],
          ),
          if (widget.showFavorites)
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Get.offAllNamed('/home'),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed('/search'),
          ),
        ],
      ),
      drawer: Menu(user: widget.user),
      body: Obx(() {
        if (controller.cocktails.isEmpty) {
          return const Center(child: CocktailFillLoading());
        }

        final displayCocktails = widget.showFavorites
            ? controller.cocktails
                .where((cocktail) =>
                    likesController.userLikedDrinks.contains(cocktail.idDrink))
                .toList()
            : sortCocktailsWithFavoritesFirst(controller.cocktails);

        if (displayCocktails.isEmpty && widget.showFavorites) {
          return Center(
            child: Text(
              FlutterI18n.translate(context, 'home_screen.no_favorites'),
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }

        switch (_viewType.value) {
          case 0:
            return _buildCarouselView(displayCocktails);
          case 1:
            return _buildIBAStyleView(displayCocktails);
          case 2:
            return _buildGridView(displayCocktails);
          default:
            return _buildCarouselView(displayCocktails);
        }
      }),
    );
  }

  // Mantém o carrossel existente
  Widget _buildCarouselView(List<Cocktail> cocktails) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (context, currentIndex, _) {
              if (cocktails.isEmpty) return Container();
              if (currentIndex >= cocktails.length) {
                return Container();
              }
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey(currentIndex),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        cocktails[currentIndex].getDrinkImageUrl(),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(179),
                  Colors.black.withAlpha(51),
                  Colors.black.withAlpha(179),
                  Colors.black.withAlpha(230),
                ],
                stops: const [0.0, 0.1, 0.5, 0.9],
              ),
            ),
          ),
        ),
        if (kIsWeb)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        if (pageController.page == 0) {
                          pageController.animateToPage(
                            cocktails.length - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        } else {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        if (pageController.page == cocktails.length - 1) {
                          pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        } else {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: _currentPage,
                builder: (context, currentIndex, _) {
                  if (cocktails.isEmpty || currentIndex >= cocktails.length) {
                    return Container();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      cocktails[currentIndex].name,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: cocktails.length,
                  onPageChanged: (index) {
                    _currentPage.value = index;
                  },
                  itemBuilder: (context, index) {
                    final drink = cocktails[index];
                    return AnimatedScale(
                      scale: _currentPage.value == index ? 1.0 : 0.8,
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: () => _navigateToDetails(cocktails[index]),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        cocktails[index].getDrinkImageUrl(),
                                        width: 400,
                                        height: 300,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[900],
                                            child: const Icon(Icons.error,
                                                color: Colors.redAccent),
                                          );
                                        },
                                      ),
                                      // Adicionar o badge de versão
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: _buildRecipeStatusBadge(drink),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: StreamBuilder<DrinkLikes>(
                                  stream: likesController
                                      .getLikesStream(cocktails[index].idDrink),
                                  builder: (context, snapshot) {
                                    return Container(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: Icon(
                                          likesController.isLikedRx(
                                                  cocktails[index].idDrink)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red,
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          likesController.toggleLike(
                                              cocktails[index].idDrink);
                                          if (!_isReordering) {
                                            _isReordering = true;
                                            Future.delayed(
                                                const Duration(seconds: 20),
                                                () {
                                              if (mounted) {
                                                setState(() {
                                                  final newList =
                                                      List<Cocktail>.from(
                                                          controller.cocktails);
                                                  newList.sort((a, b) {
                                                    final aIsLiked =
                                                        likesController
                                                            .isLikedRx(
                                                                a.idDrink);
                                                    final bIsLiked =
                                                        likesController
                                                            .isLikedRx(
                                                                b.idDrink);

                                                    if (aIsLiked && !bIsLiked) {
                                                      return -1;
                                                    }
                                                    if (!aIsLiked && bIsLiked) {
                                                      return 1;
                                                    }
                                                    return 0;
                                                  });
                                                  controller.cocktails
                                                      .assignAll(newList);
                                                  _isReordering = false;
                                                });
                                              }
                                            });
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeStatusBadge(Cocktail drink) {
    final status =
        Get.find<CocktailListController>().getRecipeStatus(drink.idDrink);

    if (status == null || status.type == RecipeType.original) {
      return const SizedBox.shrink();
    }

    final isOfficial = status.type == RecipeType.official;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(179),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOfficial ? Colors.green : Colors.amber,
          width: 1,
        ),
      ),
      child: Tooltip(
        message: isOfficial
            ? FlutterI18n.translate(context, "cocktail_detail.tooltip_official")
            : FlutterI18n.translate(
                context, "cocktail_detail.tooltip_variation"),
        child: Text(
          isOfficial
              ? FlutterI18n.translate(context, "cocktail_detail.official")
              : FlutterI18n.translate(context, "cocktail_detail.variation"),
          style: TextStyle(
            color: isOfficial ? Colors.green : Colors.amber,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Novo estilo IBA
  // Estilo IBA
  Widget _buildIBAStyleView(List<Cocktail> cocktails) {
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: cocktails.length,
        itemBuilder: (context, index) {
          final drink = cocktails[index];
          return Container(
            height: 490,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () => _navigateToDetails(drink),
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
                            top: 8,
                            left: 8,
                            child: _buildRecipeStatusBadge(drink),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(128),
                                shape: BoxShape.circle,
                              ),
                              child: StreamBuilder<DrinkLikes>(
                                stream: likesController
                                    .getLikesStream(drink.idDrink),
                                builder: (context, snapshot) {
                                  return IconButton(
                                    icon: Icon(
                                      likesController.isLikedRx(drink.idDrink)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      likesController.toggleLike(drink.idDrink);
                                      if (!_isReordering) {
                                        _isReordering = true;
                                        Future.delayed(
                                          const Duration(seconds: 20),
                                          () {
                                            if (mounted) {
                                              setState(() {
                                                final newList =
                                                    sortCocktailsWithFavoritesFirst(
                                                        List<Cocktail>.from(
                                                            controller
                                                                .cocktails));
                                                controller.cocktails
                                                    .assignAll(newList);
                                                _isReordering = false;
                                              });
                                            }
                                          },
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
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
        },
      ),
    );
  }

// Grid View
  Widget _buildGridView(List<Cocktail> cocktails) {
    return SafeArea(
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: cocktails.length,
        itemBuilder: (context, index) {
          final drink = cocktails[index];
          return GestureDetector(
            onTap: () => _navigateToDetails(drink),
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
                          left: 8,
                          child: _buildRecipeStatusBadge(drink),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(128),
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
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    likesController.toggleLike(drink.idDrink);
                                    if (!_isReordering) {
                                      _isReordering = true;
                                      Future.delayed(
                                        const Duration(seconds: 20),
                                        () {
                                          if (mounted) {
                                            setState(() {
                                              final newList =
                                                  sortCocktailsWithFavoritesFirst(
                                                      List<Cocktail>.from(
                                                          controller
                                                              .cocktails));
                                              controller.cocktails
                                                  .assignAll(newList);
                                              _isReordering = false;
                                            });
                                          }
                                        },
                                      );
                                    }
                                  },
                                );
                              },
                            ),
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
      ),
    );
  }

  List<Cocktail> sortCocktailsWithFavoritesFirst(List<Cocktail> cocktails) {
    if (!widget.showFavorites) {
      final sortedList = List<Cocktail>.from(cocktails);

      // Mantém a ordem atual se estiver reordenando
      if (_isReordering) {
        return sortedList;
      }

      // Ordena normalmente
      sortedList.sort((a, b) {
        final aIsLiked = likesController.isLikedRx(a.idDrink);
        final bIsLiked = likesController.isLikedRx(b.idDrink);

        if (aIsLiked && !bIsLiked) return -1;
        if (!aIsLiked && bIsLiked) return 1;
        return 0;
      });

      return sortedList;
    }
    return cocktails;
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.dispose();
  }
}
