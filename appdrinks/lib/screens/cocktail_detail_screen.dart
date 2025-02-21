import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_netdrinks/controller/cocktail_detail_controller.dart';
import 'package:app_netdrinks/models/cocktail.dart';
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
  String _selectedLanguage = 'pt';
  final logger = Logger();
  // Alterado para usar Get.find()
  final translationService = Get.find<TranslationService>();
  late final CocktailController controller;

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

  @override
  void initState() {
    super.initState();
    controller = Get.find<CocktailController>();
    _selectedLanguage = Get.locale?.languageCode ?? 'pt';
    // Garante que o serviço está inicializado
    if (!translationService.isInitialized) {
      translationService.initialize().then((_) {
        _translateContent();
      });
    } else {
      _translateContent();
    }
    controller.loadMyVersion(widget.cocktail.idDrink);
  }

  @override
  void dispose() {
    _myVersionController.dispose();
    super.dispose();
  }

  String translate(String key) => translations[key] ?? key;

  Future<void> _translateContent() async {
    final drink = widget.cocktail;

    setState(() {
      translatedAlternateName = drink.strDrinkAlternate;
      translatedCategory = drink.strCategory;
      translatedAlcohol = drink.strAlcoholic;
      translatedGlass = drink.strGlass;

      // Usando o TranslationService para buscar as instruções traduzidas
      translatedInstructions =
          translationService.translateDrinkField(drink.idDrink, 'instructions');

      translatedTags =
          drink.strTags?.split(',').map((tag) => tag.trim()).toList() ?? [];
      translatedIngredients = drink.getIngredientsWithMeasures();
    });
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.cocktail.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareScreen,
          ),
          _buildLanguageDropdown(),
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

  Widget _buildLanguageDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedLanguage,
        icon: const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.language, color: Colors.redAccent),
        ),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'pt', child: Text('Português')),
          DropdownMenuItem(value: 'es', child: Text('Español')),
          DropdownMenuItem(value: 'fr', child: Text('Français')),
          DropdownMenuItem(value: 'de', child: Text('Deutsch')),
          DropdownMenuItem(value: 'it', child: Text('Italiano')),
        ],
        onChanged: (String? newValue) async {
          if (newValue != null) {
            setState(() => _selectedLanguage = newValue);
            Get.updateLocale(Locale(newValue));
            await _translateContent();
          }
        },
      ),
    );
  }

  Widget _buildMainImage() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Image.asset(
        widget.cocktail.getDrinkImageUrl(), // Usando o método correto
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: const Icon(Icons.error, color: Colors.redAccent),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (translatedInstructions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrinkInfo(),
          if (translatedTags?.isNotEmpty ?? false) _buildTags(),
          const SizedBox(height: 16),
          _buildIngredientsList(),
          const SizedBox(height: 16),
          _buildInstructions(),
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
            '${translate("alternative_name")}: $translatedAlternateName',
            style: const TextStyle(color: Colors.white),
          ),
        ],
        _buildInfoRow(Icons.category, "category", translatedCategory),
        _buildInfoRow(Icons.local_bar, "type", translatedAlcohol),
        _buildInfoRow(Icons.wine_bar, "glass", translatedGlass),
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
            '${translate(labelKey)}: ${value ?? ""}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: translatedTags!.map((tag) {
        return Chip(
          label: Text(tag),
          backgroundColor: Colors.redAccent,
          labelStyle: const TextStyle(color: Colors.white),
        );
      }).toList(),
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate("ingredients"),
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...translatedIngredients!
            .where((ingredient) =>
                ingredient['ingredient'] != null &&
                ingredient['ingredient']!.isNotEmpty)
            .map((ingredient) => _buildIngredientItem(ingredient)),
      ],
    );
  }

  Widget _buildIngredientItem(Map<String, String> ingredient) {
    final measure = ingredient['measure'] ?? '';
    final (originalMeasure, mlMeasure) = _buildMeasureText(measure);
    final ingredientName = ingredient['ingredient'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.cocktail.getIngredientImageUrl(ingredientName),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
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
                else
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
          translate("instructions"),
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          translatedInstructions ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildMyVersion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate("my_version"),
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
            label: const Text(''),
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
        hintText: translate("add_your_version"),
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
