import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'tips_screen.title')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipCard(
                context,
                icon: FontAwesomeIcons.magic,
                title: FlutterI18n.translate(context, 'tips_screen.tip1_title'),
                content:
                    FlutterI18n.translate(context, 'tips_screen.tip1_content'),
              ),
              _buildTipCard(
                context,
                icon: FontAwesomeIcons.child,
                title: FlutterI18n.translate(context, 'tips_screen.tip2_title'),
                content:
                    FlutterI18n.translate(context, 'tips_screen.tip2_content'),
              ),
              _buildTipCard(
                context,
                icon: FontAwesomeIcons.language,
                title: FlutterI18n.translate(context, 'tips_screen.tip3_title'),
                content:
                    FlutterI18n.translate(context, 'tips_screen.tip3_content'),
              ),
              _buildTipCard(
                context,
                icon: FontAwesomeIcons.starHalfAlt,
                title: FlutterI18n.translate(context, 'tips_screen.tip4_title'),
                content:
                    FlutterI18n.translate(context, 'tips_screen.tip4_content'),
              ),
              _buildTipCard(
                context,
                icon: FontAwesomeIcons.trophy,
                title: FlutterI18n.translate(context, 'tips_screen.tip5_title'),
                content:
                    FlutterI18n.translate(context, 'tips_screen.tip5_content'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(icon,
                    size: 24, color: const Color.fromARGB(255, 131, 4, 4)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
