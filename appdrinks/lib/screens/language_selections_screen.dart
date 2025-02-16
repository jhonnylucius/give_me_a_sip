import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    await prefs.setBool('selected_language', true);
    Get.updateLocale(Locale(languageCode));
    Get.offAllNamed('/home'); // Redireciona para a tela inicial
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            FlutterI18n.translate(context, 'language_selection_screen.title')),
        automaticallyImplyLeading: false, // Impede o botão de voltar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _saveLanguage('en'),
              child: Text(
                FlutterI18n.translate(
                    context, 'language_selection_screen.english'),
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () => _saveLanguage('pt'),
              child: Text(
                FlutterI18n.translate(
                    context, 'language_selection_screen.portuguese'),
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () => _saveLanguage('es'),
              child: Text(
                FlutterI18n.translate(
                    context, 'language_selection_screen.spanish'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
