import 'package:app_netdrinks/screens/verify_email_screen.dart';
import 'package:app_netdrinks/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final AuthService _authService = AuthService();

  RegisterScreen({Key? key}) : super(key: key);

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
                child: Column(
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
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(labelText: 'E-mail'),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      obscureText: true,
                      controller: _senhaController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(labelText: 'Senha'),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      obscureText: true,
                      controller: _confirmarSenhaController,
                      style: const TextStyle(color: Colors.black),
                      decoration:
                          const InputDecoration(labelText: 'Confirmar Senha'),
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_senhaController.text ==
                            _confirmarSenhaController.text) {
                          final result = await _authService.cadastrarUsuario(
                            email: _emailController.text,
                            senha: _senhaController.text,
                            nome: _nomeController.text,
                            context: context,
                          );

                          if (result == null) {
                            // Cadastro bem-sucedido. Obtém o usuário autenticado.
                            final user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              // Navega para a tela de verificação de e-mail, passando o usuário.
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VerifyEmailScreen(user: user),
                                ),
                              );
                            } else {
                              // Lidar com o caso em que o usuário é nulo após o cadastro (improvável, mas possível)
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Erro ao obter usuário após o cadastro.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            // Houve um erro no cadastro.
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          // Senhas não coincidem.
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Senhas não conferem.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Cadastrar'),
                    ),
                    const SizedBox(height: 8.0),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Já tenho uma conta!'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
