import 'package:app_netdrinks/components/menu.dart';
import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/screens/cocktail_detail_screen.dart';
import 'package:app_netdrinks/widgets/cocktail_card_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';

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
  late final CocktailController controller;

  double _viewportFraction = 0.7;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CocktailController>();
    _initializePageController();
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
            ? FlutterI18n.translate(context, 'Favoritos')
            : FlutterI18n.translate(context, 'NetDrinks')),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (widget.showFavorites)
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
        if (controller.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final displayCocktails = widget.showFavorites
            ? controller.getFavoriteCocktails()
            : controller.cocktails;

        if (displayCocktails.isEmpty && widget.showFavorites) {
          return Center(
            child: Text(
              FlutterI18n.translate(context,
                  'Você não tem Drinks Salvos,\n clique no coração ao lado da foto do Drink pra salvá-lo como favorito!'),
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ValueListenableBuilder<int>(
                valueListenable: _currentPage,
                builder: (context, currentIndex, _) {
                  if (displayCocktails.isEmpty) return Container();
                  if (currentIndex >= displayCocktails.length) {
                    return Container();
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      key: ValueKey(currentIndex),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            displayCocktails[currentIndex].imageUrl,
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
                                displayCocktails.length - 1,
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
                            if (pageController.page ==
                                displayCocktails.length - 1) {
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
                      if (displayCocktails.isEmpty ||
                          currentIndex >= displayCocktails.length) {
                        return Container();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          displayCocktails[currentIndex].name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
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
                    height: 200,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: displayCocktails.length,
                      onPageChanged: (index) {
                        _currentPage.value = index;
                      },
                      itemBuilder: (context, index) {
                        return AnimatedScale(
                          scale: _currentPage.value == index ? 1.0 : 0.8,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () =>
                                _navigateToDetails(displayCocktails[index]),
                            child: CocktailCard(
                              cocktail: displayCocktails[index],
                              user: widget.user.uid,
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
      }),
    );
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.dispose();
  }
}
