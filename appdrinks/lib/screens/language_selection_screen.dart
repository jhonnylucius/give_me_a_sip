import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    Get.updateLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _saveLanguage('en');
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('English'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveLanguage('pt');
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Português'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveLanguage('es');
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Español'),
            ),
          ],
        ),
      ),
    );
  }
}
