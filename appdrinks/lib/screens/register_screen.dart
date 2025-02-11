import 'package:app_netdrinks/screens/verify_email_screen.dart';
import 'package:app_netdrinks/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Obx(() => _isLoading.value
                    ? const SizedBox()
                    : Column(
                        children: [
                          Image.asset(
                            'assets/Icon-192.png',
                            width: 90,
                            height: 90,
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            controller: _nomeController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, 'register.name'),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, 'register.email'),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            obscureText: true,
                            controller: _senhaController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, 'register.password'),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            obscureText: true,
                            controller: _confirmarSenhaController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: FlutterI18n.translate(
                                  context, 'register.confirm_password'),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () async {
                              if (_senhaController.text ==
                                  _confirmarSenhaController.text) {
                                _isLoading.value = true;

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
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VerifyEmailScreen(user: user),
                                          ),
                                        );
                                      }
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
                            child: Text(FlutterI18n.translate(
                                context, 'register.register')),
                          ),
                          const SizedBox(height: 8.0),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(FlutterI18n.translate(
                                context, 'register.already_have_account')),
                          ),
                        ],
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
