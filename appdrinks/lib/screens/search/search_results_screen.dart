import 'package:app_netdrinks/controller/search_controller.dart' as custom;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultsScreen extends StatelessWidget {
  final custom.SearchController controller = Get.find();
  SearchResultsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados da Pesquisa'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.searchResults.isEmpty) {
          return Center(
            child: Text(
              'Nenhum resultado encontrado',
              style: TextStyle(fontSize: 18),
            ),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final cocktail = controller.searchResults[index];
            return CocktailCard(
              cocktail: cocktail,
              user: '',
            );
          },
        );
      }),
    );
  }
}

class CocktailCard extends StatelessWidget {
  final dynamic cocktail;
  final String user;
  const CocktailCard({required this.cocktail, required this.user, super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              cocktail['imageUrl'],
              height: 180, // Aumentar altura da imagem
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              cocktail['name'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
