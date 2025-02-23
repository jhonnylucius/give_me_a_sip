import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/models/drink_likes.dart';
import 'package:app_netdrinks/services/measurement_converter_service.dart';
import 'package:app_netdrinks/services/translation_service.dart';
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

        // Traduzir valores principais usando o serviço de tradução
        translatedCategory =
            translationService.translateDrinkField(drink.idDrink, 'category') ??
                drink.strCategory;

        translatedAlcohol = translationService.translateDrinkField(
                drink.idDrink, 'alcoholic') ??
            drink.strAlcoholic;

        translatedGlass =
            translationService.translateDrinkField(drink.idDrink, 'glass') ??
                drink.strGlass;

        // Resto do código permanece igual
        translatedInstructions = translationService.translateDrinkField(
            drink.idDrink, 'instructions');

        // Para ingredientes
        translatedIngredients = [];
        for (var i = 0; i < drink.ingredients.length; i++) {
          final ingredient = drink.ingredients.elementAt(i);
          if (ingredient != null && ingredient.isNotEmpty) {
            final measure = i < drink.measures.length ? drink.measures[i] : '';

            translatedIngredients!.add({
              'name': translationService.translateIngredient(ingredient),
              'measure': measure ?? '',
              'imageUrl':
                  'ingredients/${ingredient.toLowerCase().replaceAll(' ', '_')}.png'
            });
          }
        }

        // Tags
        if (drink.strTags != null) {
          translatedTags = drink.strTags!
              .split(',')
              .map((tag) => tag.trim())
              .map((tag) => translationService.translateTag(tag))
              .toList();
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
          final imagePath = '${directory.path}/drink.png';
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
          if (translatedTags?.isNotEmpty ?? false) _buildTags(),
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
          translationService
                  .getInterfaceString('cocktail_detail.ingredients') ??
              'Ingredients',
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/data/images/${ingredient['imageUrl']}',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[900],
                  child: const Icon(Icons.no_drinks, color: Colors.redAccent),
                );
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
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                if (mlMeasure != null)
                  Text(
                    '$originalMeasure ($mlMeasure)',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  )
                else if (originalMeasure.isNotEmpty)
                  Text(
                    originalMeasure,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
          translationService
                  .getInterfaceString('cocktail_detail.instructions') ??
              'Instructions',
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
          translationService.getInterfaceString('cocktail_detail.my_version') ??
              'My Version',
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
              translationService.getInterfaceString('cocktail_detail.edit') ??
                  'Edit',
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
}
