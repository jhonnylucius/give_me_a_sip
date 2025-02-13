import 'package:app_netdrinks/services/auth_services.dart';
import 'package:app_netdrinks/widgets/retro_loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final AuthService _authService = AuthService();
  final _isLoading = false.obs;

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_login.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: kIsWeb ? 400 : null,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.8 * 255).toInt()),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Colors.redAccent,
                  width: 1.0,
                ),
              ),
              child: Obx(
                () => _isLoading.value
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/Icon-192.png',
                              width: 180,
                              height: 180,
                            ),
                            const SizedBox(height: 30),
                            const SizedBox(
                              width: 220.0,
                              height: 180.0,
                              child: RetroLoadingWidget(
                                totalDrinks: 636,
                                showCounter: false,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/Icon-192.png',
                            width: 90,
                            height: 90,
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _nomeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, 'register.name'),
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, 'register.email'),
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            obscureText: true,
                            controller: _senhaController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, 'register.password'),
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            obscureText: true,
                            controller: _confirmarSenhaController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, 'register.confirm_password'),
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                            ),
                            // Substituir APENAS o bloco onPressed do ElevatedButton:
                            onPressed: () async {
                              if (_senhaController.text ==
                                  _confirmarSenhaController.text) {
                                try {
                                  final result =
                                      await _authService.cadastrarUsuario(
                                    email: _emailController.text,
                                    senha: _senhaController.text,
                                    nome: _nomeController.text,
                                    context: context,
                                  );

                                  if (result == null) {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      Get.offAllNamed(
                                          '/verify-email'); // Usa Get ao invés de Navigator
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(FlutterI18n.translate(
                                                context,
                                                'register.error_fetching_user')),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(result),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } finally {
                                  _isLoading.value = false;
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(FlutterI18n.translate(
                                          context,
                                          'register.passwords_do_not_match')),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              FlutterI18n.translate(
                                  context, 'register.register'),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              FlutterI18n.translate(
                                  context, 'register.already_have_account'),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
