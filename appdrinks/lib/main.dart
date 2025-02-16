import 'package:app_netdrinks/bindings/app_bindings.dart';
import 'package:app_netdrinks/bindings/search_binding.dart';
import 'package:app_netdrinks/firebase_options.dart';
import 'package:app_netdrinks/screens/cocktail_detail_screen.dart';
import 'package:app_netdrinks/screens/drink_ranking_screen.dart';
import 'package:app_netdrinks/screens/home_screen.dart';
import 'package:app_netdrinks/screens/language_selections_screen.dart';
import 'package:app_netdrinks/screens/login_screen.dart';
import 'package:app_netdrinks/screens/search/search_results_screen.dart';
import 'package:app_netdrinks/screens/search/search_screen.dart';
import 'package:app_netdrinks/screens/splash_screen.dart';
import 'package:app_netdrinks/screens/verify_email_screen.dart';
import 'package:app_netdrinks/services/locator_service.dart';
import 'package:app_netdrinks/widgets/terms_of_service_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupLocator();

  final prefs = await SharedPreferences.getInstance();
  final bool? termsAccepted = prefs.getBool('termsAccepted');

  // Verifica se os termos foram aceitos
  if (termsAccepted != true) {
    runApp(MyApp(showTermsDialog: true));
  } else {
    final languageCode = prefs.getString('language') ?? 'en';
    final locale = Locale(languageCode);
    runApp(MyApp(locale: locale, showTermsDialog: false));
  }
}

class MyApp extends StatelessWidget {
  final Locale? locale;
  final bool showTermsDialog;

  const MyApp({super.key, this.locale, required this.showTermsDialog});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      title: 'NetDrinks',
      locale: locale,
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            basePath: 'assets/lang',
            fallbackFile: 'en',
            useCountryCode: false,
          ),
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('pt', ''),
        Locale('es', ''),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        return supportedLocales.firstWhere(
          (supportedLocale) =>
              supportedLocale.languageCode == locale?.languageCode,
          orElse: () => supportedLocales.first,
        );
      },
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(afterVerify: true),
        ),
        GetPage(
          name: '/language-settings',
          page: () => const LanguageSelectionScreen(),
        ),
        GetPage(
          name: '/terms',
          page: () => PopScope(
            canPop: false,
            child: TermsOfServiceDialog(
              onAccepted: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('termsAccepted', true);
                Get.offAllNamed('/login');
              },
              onDeclined: () {
                Get.offAll(() => Scaffold(
                      backgroundColor: Colors.black,
                      body: PopScope(
                        canPop: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.local_bar_rounded,
                                  size: 80,
                                  color: Color.fromARGB(255, 204, 7, 17),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Para usar o NetDrinks e descobrir mais de 600 receitas incríveis de drinks, é necessário aceitar os termos de uso.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Feche o app e abra novamente para aceitar os termos.',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 204, 7, 17),
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ));
              },
            ),
          ),
        ),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(
          name: '/verify-email',
          page: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return LoginScreen();
            return VerifyEmailScreen(user: user);
          },
        ),
        GetPage(
          name: '/splash-after-verify',
          page: () => const SplashScreen(afterVerify: true),
        ),
        GetPage(
          name: '/home',
          page: () {
            final user = FirebaseAuth.instance.currentUser;
            final showFavorites = Get.parameters['showFavorites'] == 'true';
            if (user == null) return LoginScreen();
            return HomeScreen(user: user, showFavorites: showFavorites);
          },
        ),
        GetPage(
          name: '/favorites',
          page: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return LoginScreen();
            return HomeScreen(user: user, showFavorites: true);
          },
        ),
        GetPage(
          name: '/search',
          page: () => const SearchScreen(),
          binding: SearchBinding(),
        ),
        GetPage(
          name: '/search-results',
          page: () => SearchResultsScreen(),
        ),
        GetPage(
          name: '/cocktail-detail',
          page: () => CocktailDetailScreen(cocktail: Get.arguments),
        ),
        GetPage(
          name: '/ranking',
          page: () => const RankingScreen(),
        ),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 204, 7, 17),
          brightness: Brightness.dark,
          primary: const Color.fromARGB(255, 204, 7, 17),
          secondary: const Color(0xFFFFFFFF),
          surface: const Color(0xFF000000),
          onPrimary: const Color(0xFFFFFFFF),
          onSecondary: const Color(0xFF000000),
          onSurface: const Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          foregroundColor: Color.fromARGB(255, 204, 7, 17),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF121212),
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
          bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
          titleLarge: TextStyle(color: Color.fromARGB(255, 204, 7, 17)),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: showTermsDialog
          ? PopScope(
              canPop: false,
              child: TermsOfServiceDialog(
                onAccepted: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('termsAccepted', true);
                  Get.offAllNamed('/login');
                },
                onDeclined: () {
                  Get.offAll(() => Scaffold(
                        backgroundColor: Colors.black,
                        body: PopScope(
                          canPop: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.local_bar_rounded,
                                    size: 80,
                                    color: Color.fromARGB(255, 204, 7, 17),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Para usar o NetDrinks e descobrir mais de 600 receitas incríveis de drinks, é necessário aceitar os termos de uso.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Feche o app e abra novamente para aceitar os termos.',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 204, 7, 17),
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ));
                },
              ),
            )
          : null,
    );
  }
}
