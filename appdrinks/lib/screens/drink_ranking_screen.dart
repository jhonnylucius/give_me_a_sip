import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../contants/ranking_contants.dart';
import '../controller/ranking_controller.dart';
import '../widgets/ranking_list.dart';

class RankingScreen extends GetView<RankingController> {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(RankingConstants.rankingTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshRanking(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshRanking,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.error.value),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.refreshRanking,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (controller.rankedDrinks.isEmpty) {
            return const Center(
              child: Text('Nenhum drink encontrado no ranking'),
            );
          }

          return RankingList(drinks: controller.rankedDrinks);
        }),
      ),
    );
  }
}
