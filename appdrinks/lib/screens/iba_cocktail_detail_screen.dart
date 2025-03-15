import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_netdrinks/controller/iba_detail_controller.dart';
import 'package:app_netdrinks/controller/likes_controller.dart';
import 'package:app_netdrinks/models/drink_likes.dart';
import 'package:app_netdrinks/models/iba_drinks.dart';
import 'package:app_netdrinks/repository/iba_drinks_repository.dart';
import 'package:app_netdrinks/services/iba_translation_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class IBACocktailDetailScreen extends StatefulWidget {
  final IBADrink drink;
  const IBACocktailDetailScreen({super.key, required this.drink});

  @override
  State<IBACocktailDetailScreen> createState() =>
      IBACocktailDetailScreenState();
}

class IBACocktailDetailScreenState extends State<IBACocktailDetailScreen> {
  final logger = Logger();
  late final IBADetailController controller;
  final TextEditingController _myVersionController = TextEditingController();
  final translationService = Get.find<IBATranslationService>();

  String? translatedCategory;
  String? translatedAlcoholic;
  String? translatedGlass;
  String? translatedInstructions;

  // Adicione esta chave global
  final GlobalKey _screenShotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = Get.put(IBADetailController(Get.find<IBADrinksRepository>()));
    controller.loadDrinkDetails(widget.drink.id);
    _loadTranslations();
  }

  @override
  void dispose() {
    _myVersionController.dispose();
    super.dispose();
  }

  void _loadTranslations() {
    translatedCategory =
        translationService.translateField(widget.drink.id, 'category');
    translatedAlcoholic =
        translationService.translateField(widget.drink.id, 'alcoholic');
    translatedGlass = widget.drink.glass;
    translatedInstructions =
        translationService.translateField(widget.drink.id, 'instructions');
    setState(() {});
  }

  // Adicione este método
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
          final imagePath = '${directory.path}/iba_drink.webp';
          final imgFile = File(imagePath);
          await imgFile.writeAsBytes(byteData.buffer.asUint8List());

          await Share.shareXFiles([XFile(imagePath)],
              text: 'Confira esta receita do IBA: ${widget.drink.name}!');
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
        title: Text(widget.drink.name),
        backgroundColor: Colors.black,
        actions: [
          StreamBuilder<DrinkLikes>(
            stream: Get.find<LikesController>().getLikesStream(widget.drink.id),
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(
                  Get.find<LikesController>().isLikedRx(widget.drink.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () =>
                    Get.find<LikesController>().toggleLike(widget.drink.id),
              );
            },
          ),
          IconButton(
            onPressed: _shareScreen,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: RepaintBoundary(
            key: _screenShotKey,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0,
                  MediaQuery.of(context).padding.bottom + 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.drink.getDrinkImageUrl(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.local_bar,
                              color: Colors.redAccent,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.drink.name,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Categoria', translatedCategory ?? ''),
                        _buildInfoRow('Tipo', translatedAlcoholic ?? ''),
                        _buildInfoRow('Copo', translatedGlass ?? ''),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildIngredientsList(),
                  const SizedBox(height: 24),
                  const Text(
                    'Modo de Preparo',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      translatedInstructions ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMyVersion(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredientes',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.ingredients.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = controller.ingredients[index];
              final name = ingredient['name'] ?? '';
              final measure = ingredient['measure'] ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_bar,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (measure.isNotEmpty)
                            Expanded(
                              flex: 1,
                              child: Text(
                                measure,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildMyVersion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minha Versão',
          style: TextStyle(
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
                child: Text(
                  version,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => controller.deleteMyVersion(widget.drink.id),
              ),
            ],
          ),
          TextButton.icon(
            icon: const Icon(Icons.edit, color: Colors.redAccent),
            label: const Text(
              'Editar',
              style: TextStyle(color: Colors.redAccent),
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
        hintText: 'Adicione sua versão...',
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
                widget.drink.id,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
