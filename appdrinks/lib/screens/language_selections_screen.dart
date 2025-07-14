import 'package:app_netdrinks/services/translation_service.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static const Map<String, Map<String, String>> supportedLanguages = {
    'pt': {'name': 'Português', 'country': 'BR'},
    'en': {'name': 'English', 'country': 'US'},
    'es': {'name': 'Español', 'country': 'ES'},
    'fr': {'name': 'Français', 'country': 'FR'},
    'it': {'name': 'Italiano', 'country': 'IT'},
    'de': {'name': 'Deutsch', 'country': 'DE'},
  };

  Future<void> _saveLanguage(String languageCode) async {
    try {
      final translationService = Get.find<TranslationService>();
      await translationService.setLanguage(languageCode);

      // Salva o idioma nas preferências
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);

      Get.offAllNamed('/home');
    } catch (e) {
      Logger().e('Erro ao salvar idioma: $e');
    }
  }

  Widget _buildLanguageCard(
      String languageCode, Map<String, String> languageInfo) {
    return Card(
      color: const Color.fromARGB(255, 0, 0, 0),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CountryFlag.fromCountryCode(
              languageInfo['country']!,
              height: 32,
              width: 32,
              shape: const RoundedRectangle(12),
            ),
            const SizedBox(width: 12),
            Text(
              languageInfo['name']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        onTap: () => _saveLanguage(languageCode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Text(
              'Escolha seu idioma',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final languageCode =
                          supportedLanguages.keys.elementAt(index);
                      final languageInfo = supportedLanguages[languageCode]!;
                      return _buildLanguageCard(languageCode, languageInfo);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
