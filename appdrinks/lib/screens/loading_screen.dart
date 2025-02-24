import 'package:app_netdrinks/widgets/cocktail_fill_loading.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 204, 7, 17), // Vermelho Netflix
      child: const Center(
        child: CocktailFillLoading(
          color: Color.fromARGB(255, 204, 7, 17),
        ),
      ),
    );
  }
}
