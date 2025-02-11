import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfServiceDialog extends StatelessWidget {
  final VoidCallback onAccepted;
  final VoidCallback onDeclined;

  const TermsOfServiceDialog({
    super.key,
    required this.onAccepted,
    required this.onDeclined,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(FlutterI18n.translate(context, 'terms_of_service_dialog.title')),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(FlutterI18n.translate(
                context, 'terms_of_service_dialog.content')),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () =>
                  _launchURL('https://union.dev.br/termosNetDrinks.html'),
              child: Text(
                FlutterI18n.translate(
                    context, 'terms_of_service_dialog.read_terms'),
                style: const TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
              FlutterI18n.translate(context, 'terms_of_service_dialog.accept')),
          onPressed: () {
            Navigator.of(context).pop(); // Fechar o diálogo
            onAccepted();
          },
        ),
        TextButton(
          child: Text(FlutterI18n.translate(
              context, 'terms_of_service_dialog.decline')),
          onPressed: () {
            Navigator.of(context).pop(); // Fechar o diálogo
            onDeclined();
          },
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
