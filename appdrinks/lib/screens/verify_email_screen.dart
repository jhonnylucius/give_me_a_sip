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
      canPop: false, // prevent back
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
                  final context = this.context;
                  await widget.user.sendEmailVerification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(FlutterI18n.translate(
                            context, 'Reenviar E-mail de Verificação')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text(FlutterI18n.translate(
                    context, 'E-mail de verificação enviado com sucesso!')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
