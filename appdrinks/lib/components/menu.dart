import 'package:app_netdrinks/screens/home_screen.dart';
import 'package:app_netdrinks/screens/tips_screen.dart';
import 'package:app_netdrinks/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class Menu extends StatelessWidget {
  final User user;

  const Menu({super.key, required this.user});

  void _confirmarExclusao(BuildContext context) {
    TextEditingController senhaController = TextEditingController();
    bool isGoogleUser = user.providerData
        .any((userInfo) => userInfo.providerId == 'google.com');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, 'menu.confirm_deletion')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FlutterI18n.translate(context, 'menu.deletion_warning'),
            ),
            if (!isGoogleUser) ...[
              const SizedBox(height: 16),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText:
                        FlutterI18n.translate(context, 'menu.enter_password')),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(FlutterI18n.translate(context, 'menu.cancel')),
          ),
          TextButton(
            onPressed: () async {
              String? erro = await AuthService().excluiConta(
                  senha: isGoogleUser ? null : senhaController.text);

              if (!context.mounted) return;
              Navigator.pop(context);

              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        FlutterI18n.translate(context, 'menu.account_deleted')),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${FlutterI18n.translate(context, 'menu.deletion_error')}: $erro'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              FlutterI18n.translate(context, 'menu.delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.displayName ??
                FlutterI18n.translate(context, 'menu.user')),
            accountEmail: Text(user.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? const Icon(Icons.emoji_emotions_sharp, size: 40)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(FlutterI18n.translate(context, 'menu.home')),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text(FlutterI18n.translate(context, 'menu.favorites')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    user: FirebaseAuth.instance.currentUser!,
                    showFavorites: true,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.lightbulb),
            title: Text(FlutterI18n.translate(context, 'menu.tips_and_news')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TipsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text(FlutterI18n.translate(context, 'menu.ranking')),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              Get.toNamed('/ranking');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title:
                Text(FlutterI18n.translate(context, 'menu.language_settings')),
            onTap: () {
              Navigator.pushNamed(context, '/language-settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(FlutterI18n.translate(context, 'menu.logout')),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text(FlutterI18n.translate(context, 'menu.delete_account')),
            onTap: () => _confirmarExclusao(context),
          ),
        ],
      ),
    );
  }
}
