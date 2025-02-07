import 'package:app_netdrinks/modal/reset_password_modal.dart';
import 'package:app_netdrinks/screens/home_screen.dart';
import 'package:app_netdrinks/screens/register_screen.dart';
import 'package:app_netdrinks/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key, this.showFavorites = false});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final AuthService _authService = AuthService();
  final bool showFavorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_login.jpg"),
            fit: BoxFit.cover,
          ),
          border: Border.all(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(4, 4),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 2,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.grey.withAlpha((0.5 * 255).toInt()),
              offset: Offset(-2, -2),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: kIsWeb ? 400 : null, // Ajuste a largura para a versão web
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                          offset: Offset(-2, -2),
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/Icon-192.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: FlutterI18n.translate(context, "login.email"),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    obscureText: true,
                    controller: _senhaController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText:
                          FlutterI18n.translate(context, "login.password"),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      final email = _emailController.text;
                      final senha = _senhaController.text;

                      if (email.isEmpty || senha.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Por favor, preencha todos os campos')),
                        );
                        return;
                      }

                      try {
                        await _authService.entrarUsuario(email, senha);
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                      user: user,
                                      showFavorites: false,
                                    )),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Erro ao fazer login: Usuário não encontrado')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao fazer login: $e')),
                        );
                      }
                    },
                    child: Text(FlutterI18n.translate(context, "Entrar")),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ResetPasswordModal(),
                      );
                    },
                    child: Text(FlutterI18n.translate(
                        context, "login.forgot_password")),
                  ),
                  SizedBox(height: 10),
                  SignInButton(
                    Buttons.Google,
                    onPressed: () async {
                      try {
                        await _authService.signInWithGoogle();
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                      user: user,
                                      showFavorites: false,
                                    )),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Erro ao fazer login com Google: Usuário não encontrado')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Erro ao fazer login com Google: $e')),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text(FlutterI18n.translate(context, "Criar Conta")),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
