import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/enums/recipe_type.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/drink_likes.dart';
import 'package:app_netdrinks/repository/iba_drinks_repository.dart';
import 'package:app_netdrinks/services/measurement_converter_service.dart';
import 'package:app_netdrinks/services/translation_service.dart';
import 'package:app_netdrinks/utils/string_normalizer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CocktailDetailScreen extends StatefulWidget {
  final Cocktail cocktail;
  const CocktailDetailScreen({super.key, required this.cocktail});

  @override
  State<CocktailDetailScreen> createState() => CocktailDetailScreenState();
}

class CocktailDetailScreenState extends State<CocktailDetailScreen> {
  final GlobalKey _screenShotKey = GlobalKey();
  final logger = Logger();
  final translationService = Get.find<TranslationService>();
  late final CocktailController controller;

  // Estados para traduções
  String? translatedAlternateName;
  String? translatedCategory;
  String? translatedAlcohol;
  String? translatedGlass;
  String? translatedInstructions;
  List<String>? translatedTags;
  List<Map<String, String>>? translatedIngredients;
  final TextEditingController _myVersionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<CocktailController>();
    _loadTranslations();
    controller.loadMyVersion(widget.cocktail.idDrink);
  }

  Future<void> _loadTranslations() async {
    if (!translationService.isInitialized) {
      await translationService.initialize();
    }
    _translateContent();
  }

  @override
  void dispose() {
    _myVersionController.dispose();
    super.dispose();
  }

  Future<void> _translateContent() async {
    try {
      final drink = widget.cocktail;

      setState(() {
        translatedAlternateName = drink.strDrinkAlternate;
        translatedCategory =
            translationService.translateDrinkField(drink.idDrink, 'category');
        translatedAlcohol =
            translationService.translateDrinkField(drink.idDrink, 'alcoholic');
        translatedGlass =
            translationService.translateDrinkField(drink.idDrink, 'glass');
        translatedInstructions = translationService.translateDrinkField(
            drink.idDrink, 'instructions');

        // Modificação principal aqui - tradução de ingredientes
        // Correção na tradução de ingredientes
        translatedIngredients = [];
        for (var i = 0; i < drink.ingredients.length; i++) {
          final ingredient = drink.ingredients[i];
          if (ingredient != null && ingredient.isNotEmpty) {
            final measure = i < drink.measures.length ? drink.measures[i] : '';
            // Usar o originalName (nome original) para buscar a tradução correta
            final originalName = drink.originalIngredients[i] ?? ingredient;
            final translatedName =
                translationService.translateIngredient(originalName);

            translatedIngredients!.add({
              'name': translatedName,
              'measure': measure ?? '',
              'originalName':
                  originalName, // Mantemos o nome original para o mapeamento de imagens
              'imageUrl': IngredientImageMapper.getImagePath(originalName) ??
                  'assets/data/images/ingredients/default.webp'
            });
          }
        }

        if (drink.strTags != null && drink.strTags!.isNotEmpty) {
          final rawTags = drink.strTags!
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();

          translatedTags = rawTags
              .map((tag) => translationService.translateTag(tag))
              .toList();
        } else {
          translatedTags = [];
        }
      });
    } catch (e, stack) {
      logger.e('Erro ao traduzir conteúdo: $e');
      logger.e('Stack: $stack');
    }
  }

  Future<void> _shareScreen() async {
    try {
      final boundary = _screenShotKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        if (kIsWeb) {
          await Share.share('Confira esta receita do NetDrinks!');
        } else {
          final directory = await getTemporaryDirectory();
          final imagePath = '${directory.path}/drink.webp';
          final imgFile = File(imagePath);
          await imgFile.writeAsBytes(byteData.buffer.asUint8List());

          await Share.shareXFiles([XFile(imagePath)],
              text: translationService
                  .getInterfaceString('share.message')
                  .replaceAll('{name}', widget.cocktail.name));
        }
      }
    } catch (e) {
      logger.e('Erro ao compartilhar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.cocktail.name),
        actions: [
          StreamBuilder<DrinkLikes>(
            stream: Get.find<LikesController>()
                .getLikesStream(widget.cocktail.idDrink),
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(
                  Get.find<LikesController>().isLikedRx(widget.cocktail.idDrink)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () => Get.find<LikesController>()
                    .toggleLike(widget.cocktail.idDrink),
              );
            },
          ),
          IconButton(
            onPressed: _shareScreen,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _screenShotKey,
          child: Column(
            children: [
              _buildMainImage(),
              _buildContent(),
              _buildRecipeInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainImage() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          // Corrigindo para usar AssetImage e o método correto do modelo
          image: AssetImage(widget.cocktail.getDrinkImageUrl()),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrinkInfo(),
          // Nova condição de exibição das tags
          if (widget.cocktail.strTags != null &&
              widget.cocktail.strTags!.isNotEmpty &&
              translatedTags != null &&
              translatedTags!.isNotEmpty)
            _buildTags(),
          const SizedBox(height: 16),
          if (translatedIngredients?.isNotEmpty ?? false)
            _buildIngredientsList(),
          const SizedBox(height: 16),
          if (translatedInstructions?.isNotEmpty ?? false) _buildInstructions(),
          const SizedBox(height: 24),
          _buildMyVersion(),
        ],
      ),
    );
  }

  Widget _buildDrinkInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.cocktail.name,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (translatedAlternateName != null) ...[
          const SizedBox(height: 8),
          Text(
            '${translationService.getInterfaceString("cocktails.alternative_name")}: $translatedAlternateName',
            style: const TextStyle(color: Colors.white),
          ),
        ],
        _buildInfoRow(
            Icons.category, 'cocktails.categories', translatedCategory),
        _buildInfoRow(
            Icons.local_bar, 'cocktails.alcoholic', translatedAlcohol),
        _buildInfoRow(Icons.wine_bar, 'cocktails.glass_type', translatedGlass),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String labelKey, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            '${translationService.getInterfaceString(labelKey)}: ${value ?? ""}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: translatedTags!.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translationService.getInterfaceString('cocktail_detail.ingredients'),
          semanticsLabel: 'Ingredients',
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...translatedIngredients!
            .map((ingredient) => _buildIngredientItem(ingredient)),
      ],
    );
  }

  Widget _buildIngredientItem(Map<String, String> ingredient) {
    final measure = ingredient['measure'] ?? '';
    final (originalMeasure, mlMeasure) = _buildMeasureText(measure);
    final ingredientName = ingredient['name'] ?? '';
    final originalName = ingredient['originalName'] ?? '';

    // Usar o nome original para buscar a imagem
    final imagePath =
        ingredient['imageUrl'] ?? 'assets/data/images/ingredients/default.webp';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.local_bar,
                    color: Colors.grey, size: 40);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                if (measure.isNotEmpty)
                  Text(
                    mlMeasure != null
                        ? '$originalMeasure ($mlMeasure)'
                        : originalMeasure,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translationService.getInterfaceString('cocktail_detail.instructions'),
          semanticsLabel: 'Instructions',
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            translatedInstructions ?? '',
            textAlign: TextAlign.justify,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildMyVersion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translationService.getInterfaceString('cocktail_detail.my_version'),
          semanticsLabel: 'My Version',
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final version = controller.currentVersion.value;
          if (version != null) {
            return _buildExistingVersion(version);
          } else {
            return _buildVersionInput();
          }
        }),
      ],
    );
  }

  Widget _buildExistingVersion(String version) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text(version, style: const TextStyle(color: Colors.white)),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () =>
                    controller.deleteMyVersion(widget.cocktail.idDrink),
              ),
            ],
          ),
          TextButton.icon(
            icon: const Icon(Icons.edit, color: Colors.redAccent),
            label: Text(
              translationService.getInterfaceString('cocktail_detail.edit'),
              semanticsLabel: 'Edit',
              style: const TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              setState(() {
                _myVersionController.text = version;
                controller.currentVersion.value = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInput() {
    return TextField(
      controller: _myVersionController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: translationService
            .getInterfaceString('cocktail_detail.add_your_version'),
        hintStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.save, color: Colors.redAccent),
          onPressed: () {
            if (_myVersionController.text.isNotEmpty) {
              controller.saveMyVersion(
                widget.cocktail.idDrink,
                _myVersionController.text,
              );
              _myVersionController.clear();
            }
          },
        ),
      ),
      maxLines: 3,
    );
  }

  (String, String?) _buildMeasureText(String measure) {
    if (MeasurementConverter.measurementRegex.hasMatch(measure)) {
      return (measure, MeasurementConverter.convertToMl(measure));
    }
    return (measure, null);
  }

  Widget _buildRecipeInfo() {
    final status = Get.find<CocktailListController>()
        .getRecipeStatus(widget.cocktail.idDrink);
    final translationService = Get.find<TranslationService>();

    if (status == null || status.type == RecipeType.original) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.type == RecipeType.official
            ? Colors.green.withAlpha((0.1 * 255).toInt())
            : Colors.amber.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status.type == RecipeType.official
              ? Colors.green
              : const ui.Color.fromARGB(255, 167, 5, 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.type == RecipeType.official
                ? translationService
                    .getInterfaceString('cocktail_detail.official')
                : translationService
                    .getInterfaceString('cocktail_detail.variation'),
            style: TextStyle(
              color: status.type == RecipeType.official
                  ? Colors.green
                  : Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (status.type == RecipeType.variation &&
              status.ibaReference != null)
            FutureBuilder(
              future: Get.find<IBADrinksRepository>()
                  .getDrinkById(status.ibaReference!),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return TextButton(
                    onPressed: () => Get.toNamed(
                      '/iba-detail',
                      arguments: snapshot.data,
                    ),
                    child: Text(
                      translationService
                          .getInterfaceString('cocktail_detail.see_original'),
                      style: const TextStyle(
                        color: ui.Color.fromARGB(255, 204, 7, 17),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }
}
