import 'package:app_netdrinks/controller/cocktail_list_controller.dart';
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
        title: Text(FlutterI18n.translate(context, 'Confirmar a exclusão')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FlutterI18n.translate(context,
                  'Esta ação não pode ser desfeita. Deseja continuar?'),
            ),
            if (!isGoogleUser) ...[
              const SizedBox(height: 16),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText:
                        FlutterI18n.translate(context, 'Digite sua senha')),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(FlutterI18n.translate(context, 'Cancelar')),
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
                    content: Text(FlutterI18n.translate(
                        context, 'Conta excluída com sucesso')),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(FlutterI18n.translate(
                        context, 'Erro ao excluir conta: $erro')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              FlutterI18n.translate(context, 'Excluir'),
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
            accountName: Text(user.displayName ?? 'Usuário'),
            accountEmail: Text(user.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? Icon(Icons.emoji_emotions_sharp,
                      size: 40) // Added icon when no photoURL
                  : null,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(FlutterI18n.translate(context, 'Home')),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text(FlutterI18n.translate(context, 'Favoritos')),
            onTap: () {
              Get.find<CocktailListController>();
              Get.to(() => HomeScreen(
                    user: FirebaseAuth.instance.currentUser!,
                    showFavorites: true,
                  ));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.lightbulb),
            title: const Text('Dicas e Novidades'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TipsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(FlutterI18n.translate(context, 'Sair')),
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text(FlutterI18n.translate(context, 'Excuir Conta')),
            onTap: () => _confirmarExclusao(context),
          ),
        ],
      ),
    );
  }
}
