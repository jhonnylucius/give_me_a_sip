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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                16.0, 16.0, 16.0, MediaQuery.of(context).padding.bottom + 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nova funcionalidade de busca multilíngue
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.language,
                  title: FlutterI18n.translate(
                      context, 'tips_screen.multilanguage_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.multilanguage_content'),
                ),
                // Nova funcionalidade de likes
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.thumbsUp,
                  title:
                      FlutterI18n.translate(context, 'tips_screen.likes_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.likes_content'),
                ),
                // Funcionalidades existentes
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.magic,
                  title:
                      FlutterI18n.translate(context, 'tips_screen.tip1_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.tip1_content'),
                ),
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.child,
                  title:
                      FlutterI18n.translate(context, 'tips_screen.tip2_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.tip2_content'),
                ),
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.starHalfAlt,
                  title:
                      FlutterI18n.translate(context, 'tips_screen.tip4_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.tip4_content'),
                ),

                // Modo Offline
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.wifi,
                  title: FlutterI18n.translate(
                      context, 'tips_screen.offline_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.offline_content'),
                ),

                // Feedback
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.comment,
                  title: FlutterI18n.translate(
                      context, 'tips_screen.feedback_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.feedback_content'),
                ),

                // Harmonização (Em breve)
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.wineGlass,
                  title: FlutterI18n.translate(
                      context, 'tips_screen.coming_soon_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.coming_soon_content'),
                ),
                // Personalização
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.userCog,
                  title: FlutterI18n.translate(
                      context, 'tips_screen.personalization_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.personalization_content'),
                ),

                // Segurança
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.shieldAlt,
                  title: FlutterI18n.translate(
                      context, 'tips_screen.safety_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.safety_content'),
                ),

                // Dica Profissional
                _buildTipCard(
                  context,
                  icon: FontAwesomeIcons.cocktail,
                  title: FlutterI18n.translate(
                      context, 'tips_screen.pro_tip_title'),
                  content: FlutterI18n.translate(
                      context, 'tips_screen.pro_tip_content'),
                ),
              ],
            ),
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
