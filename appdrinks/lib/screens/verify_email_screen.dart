import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class VerifyEmailScreen extends StatefulWidget {
  final User user;

  const VerifyEmailScreen({super.key, required this.user});

  @override
  VerifyEmailScreenState createState() => VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          _navigateToHome();
          timer.cancel();
        }
      }
    });
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'Verificar E-mail')),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                FlutterI18n.translate(context,
                    'Um e-mail de verificação foi enviado para {email}',
                    translationParams: {'email': widget.user.email!}),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Text(
                FlutterI18n.translate(context,
                    'Por favor, verifique seu e-mail e clique no link de verificação.'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () async {
                  try {
                    //final context = this.context;  Não precisa, o `context` do `build` já está no escopo.
                    await widget.user.sendEmailVerification();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(FlutterI18n.translate(context,
                              'E-mail de verificação reenviado com sucesso!')), // Mensagem mais apropriada
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(FlutterI18n.translate(context,
                              'Erro ao enviar email. Tente novamente.')),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  FlutterI18n.translate(
                      context, 'Reenviar E-mail de Verificação'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
