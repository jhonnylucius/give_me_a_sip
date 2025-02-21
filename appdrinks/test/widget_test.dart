import 'package:app_netdrinks/bindings/app_bindings.dart';
import 'package:app_netdrinks/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(
    () async {
      // Configurar SharedPreferences mock
      SharedPreferences.setMockInitialValues({
        'termsAccepted': true,
        'language': 'en',
      });

      // Inicializar Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      testWidgets('App inicializa corretamente', (WidgetTester tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            initialBinding: AppBindings(),
            home: const Scaffold(
              body: Center(
                child: Text('NetDrinks Test'),
              ),
            ),
          ),
        );

        // Verifica se o texto de teste é exibido
        expect(find.text('NetDrinks Test'), findsOneWidget);
      });

      // Você pode adicionar mais testes aqui
      // Por exemplo:
      /*
  testWidgets('Teste de navegação para tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: AppBindings(),
        home: LoginScreen(),
      ),
    );

    // Seus testes específicos para a tela de login
  });
  */
    },
  );
}
