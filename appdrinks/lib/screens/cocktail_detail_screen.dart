import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/services/azure_translation_service.dart';
import 'package:app_netdrinks/widgets/cocktail_fill_loading.dart';
import 'package:flutter/foundation.dart' show ByteData, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/measurement_converter_service.dart';
import '../widgets/network_image_handler.dart';

class CocktailDetailScreen extends StatefulWidget {
  final Cocktail cocktail;

  const CocktailDetailScreen({super.key, required this.cocktail});

  @override
  CocktailDetailScreenState createState() => CocktailDetailScreenState();
}

class CocktailDetailScreenState extends State<CocktailDetailScreen> {
  final GlobalKey _screenShotKey = GlobalKey();
  String _selectedLanguage = 'pt';
  final logger = Logger();
  final AzureTranslationService translationService =
      Get.find<AzureTranslationService>();
  final CocktailController controller = Get.find<CocktailController>();

  String? translatedAlternateName;
  String? translatedCategory;
  String? translatedAlcohol;
  String? translatedGlass;
  String? translatedInstructions;
  List<String>? translatedTags;
  List<Map<String, String>>? translatedIngredients;

  final TextEditingController _myVersionController = TextEditingController();

  final Map<String, String> translations = {
    'alternative_name': 'Nome Alternativo',
    'category': 'Categoria',
    'type': 'Tipo',
    'glass': 'Copo',
    'ingredients': 'Ingredientes',
    'instructions': 'Instruções',
    'my_version': 'Minha Versão',
    'add_your_version': 'Adicione sua versão...',
    'conversion': 'Conversão automática para ML',
    'share.message': 'Confira esta receita de '
  };

  String translate(String key) {
    return translations[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = Get.locale?.languageCode ?? 'pt';
    _translateContent();
    controller.loadMyVersion(widget.cocktail.idDrink);
  }

  @override
  void dispose() {
    _myVersionController.dispose();
    super.dispose();
  }

  Future<void> _translateContent() async {
    if (_selectedLanguage != 'en') {
      translatedAlternateName =
          await _translateText(widget.cocktail.strDrinkAlternate);
      translatedCategory = await _translateText(widget.cocktail.category);
      translatedAlcohol = await _translateText(widget.cocktail.alcohol);
      translatedGlass = await _translateText(widget.cocktail.strGlass);
      translatedInstructions =
          await _translateText(widget.cocktail.instructions);
      translatedTags = await _translateTags(widget.cocktail.strTags);
      translatedIngredients = await _translateIngredients(
          widget.cocktail.getIngredientsWithMeasures());
    } else {
      translatedAlternateName = widget.cocktail.strDrinkAlternate;
      translatedCategory = widget.cocktail.category;
      translatedAlcohol = widget.cocktail.alcohol;
      translatedGlass = widget.cocktail.strGlass;
      translatedInstructions = widget.cocktail.instructions;
      translatedTags =
          widget.cocktail.strTags?.split(',').map((tag) => tag.trim()).toList();
      translatedIngredients = widget.cocktail.getIngredientsWithMeasures();
    }
    setState(() {});
  }

  Future<String?> _translateText(String? text) async {
    if (text == null || text.isEmpty) return text;
    if (RegExp(r'^\d+$').hasMatch(text)) return text;

    try {
      return await translationService.translate(text, _selectedLanguage);
    } catch (e) {
      logger.e("Erro ao traduzir: $e");
      return text;
    }
  }

  Future<List<String>> _translateTags(String? tags) async {
    if (tags == null) return [];
    final tagList = tags.split(',').map((tag) => tag.trim()).toList();
    final translatedTagList =
        await Future.wait(tagList.map((tag) => _translateText(tag)));
    return translatedTagList.whereType<String>().toList();
  }

  Future<List<Map<String, String>>> _translateIngredients(
      List<Map<String, String>>? ingredients) async {
    if (ingredients == null) return [];

    return await Future.wait(ingredients.map((ingredient) async {
      final translatedIngredient =
          await _translateText(ingredient['ingredient']);
      return {
        'ingredient': translatedIngredient ?? '',
        'measure': ingredient['measure'] ?? '',
        'originalName': ingredient['originalName'] ?? ''
      };
    }));
  }

  Future<void> _shareScreen() async {
    try {
      RenderRepaintBoundary boundary = _screenShotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        if (kIsWeb) {
          await Share.share('Confira esta receita do NetDrinks!');
        } else {
          final directory = await getTemporaryDirectory();
          final imagePath = '${directory.path}/drink.png';
          File imgFile = File(imagePath);
          await imgFile.writeAsBytes(byteData.buffer.asUint8List());
          await Share.shareXFiles([XFile(imagePath)],
              text: '${translate("share.message")}${widget.cocktail.name}');
        }
      }
    } catch (e) {
      logger.e('Erro ao compartilhar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cocktail.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareScreen,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              icon: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child:
                    Icon(Icons.language, color: Color.fromARGB(255, 151, 4, 4)),
              ),
              items: const [
                DropdownMenuItem<String>(
                  value: 'en',
                  child: Text('English', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'pt',
                  child:
                      Text('Português', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'es',
                  child: Text('Español', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  await _translateContent();
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _screenShotKey,
          child: _buildFullContent(),
        ),
      ),
    );
  }

  Widget _buildFullContent() {
    if (translatedInstructions == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Substitua os Image.network por NetworkImageHandler
          // No método _buildFullContent():
          Center(
            child: NetworkImageHandler(
              imageUrl: widget.cocktail.imageUrl,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CocktailFillLoading(),
                ),
              ),
              height: 200,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            widget.cocktail.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (translatedAlternateName != null) ...[
            SizedBox(height: 8.0),
            Text(
              '${translate("alternative_name")}: $translatedAlternateName',
              style: TextStyle(color: Colors.white),
            ),
          ],
          SizedBox(height: 8.0),
          Row(
            children: [
              Icon(Icons.category, color: Colors.redAccent),
              SizedBox(width: 8.0),
              Text(
                '${translate("category")}: $translatedCategory',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Icon(Icons.local_bar, color: Colors.redAccent),
              SizedBox(width: 8.0),
              Text(
                '${translate("type")}: $translatedAlcohol',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Icon(Icons.wine_bar, color: Colors.redAccent),
              SizedBox(width: 8.0),
              Text(
                '${translate("glass")}: $translatedGlass',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          if (translatedTags != null && translatedTags!.isNotEmpty) ...[
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: translatedTags!.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.redAccent,
                  labelStyle: TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 16.0),
          Text(
            translate("ingredients"),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 4.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha((0.3 * 255).toInt()),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.liquor,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 8.0),
                Text(
                  translate("conversion"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (translatedIngredients != null) ...[
            SizedBox(height: 12.0),
            ...translatedIngredients!
                .where((ingredient) =>
                    ingredient['ingredient'] != null &&
                    ingredient['ingredient']!.isNotEmpty)
                .map((ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _buildIngredientItem(ingredient),
                    )),
          ],
          SizedBox(height: 16.0),
          Text(
            translate("instructions"),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.0),
          Text(
            translatedInstructions ?? '',
            style: TextStyle(color: Colors.white),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                translate("my_version"),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final version = controller.currentVersion.value;
                if (version != null) {
                  return Container(
                    padding: EdgeInsets.all(12),
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
                              child: Text(
                                version,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () async {
                                await controller
                                    .deleteMyVersion(widget.cocktail.idDrink);
                              },
                            ),
                          ],
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.edit, color: Colors.redAccent),
                          label: Text('',
                              style: TextStyle(color: Colors.redAccent)),
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
                } else {
                  return TextField(
                    controller: _myVersionController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: translate("add_your_version"),
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.save, color: Colors.redAccent),
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
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(Map<String, String> ingredient) {
    final measure = ingredient['measure'] ?? '';
    final (originalMeasure, mlMeasure) = _buildMeasureText(measure);

    return Row(
      children: [
        // No método _buildIngredientItem():
        NetworkImageHandler(
          imageUrl: widget.cocktail
              .getIngredientImageUrl(ingredient['originalName'] ?? ''),
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(8),
          placeholder: (context, url) => Container(),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ingredient['ingredient'] ?? ''),
              if (mlMeasure != null)
                Row(
                  children: [
                    Text(originalMeasure, style: TextStyle(color: Colors.grey)),
                    Text(' ($mlMeasure)',
                        style: TextStyle(color: Colors.grey[400])),
                  ],
                )
              else
                Text(originalMeasure, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  (String, String?) _buildMeasureText(String measure) {
    if (MeasurementConverter.measurementRegex.hasMatch(measure)) {
      return (measure, MeasurementConverter.convertToMl(measure));
    }
    return (measure, null);
  }
}
