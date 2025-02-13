import 'package:app_netdrinks/widgets/retro_loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required bool afterVerify});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _animationCompleted = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Inicia a animação e configura o timer para mudar de tela
    _controller.forward().whenComplete(() {
      setState(() {
        _animationCompleted = true;
      });
      // Remove o delay extra e usa apenas o tempo da animação
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final prefs = await SharedPreferences.getInstance();
      final hasSelectedLanguage = prefs.getBool('selected_language') ?? false;

      if (!hasSelectedLanguage) {
        Get.offAllNamed('/language-settings');
      } else if (user == null) {
        Get.offAllNamed('/login');
      } else if (!user.emailVerified) {
        Get.offAllNamed('/verify-email');
      } else {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print('Erro em _initializeApp: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              FadeTransition(
                opacity: _animation,
                child: ScaleTransition(
                  scale: _animation,
                  child: Image.asset(
                    'assets/Icon-192.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Título animado
              FadeTransition(
                opacity: _animation,
                child: Text(
                  'NetDrinks',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 204, 7, 17),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Loading indicator estilizado
              AnimatedOpacity(
                opacity: _animationCompleted ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 1000),
                child: SizedBox(
                  width: 220.0, // Aumentar o tamanho para melhor visualização
                  height: 180.0, // Aumentar o tamanho para melhor visualização
                  child: RetroLoadingWidget(
                    totalDrinks: 636,
                    showCounter: false, // Example total drinks count
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
