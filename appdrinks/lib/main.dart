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
  final languageCode = prefs.getString('language') ?? 'en';
  final locale = Locale(languageCode);

  runApp(MyApp(locale: locale));
}

class MyApp extends StatelessWidget {
  final Locale locale;

  const MyApp({super.key, required this.locale});

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
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});
  @override
  InitialScreenState createState() => InitialScreenState();
}

class InitialScreenState extends State<InitialScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    _checkTermsAccepted();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkTermsAccepted();
    }
  }

  Future<void> _checkTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? termsAccepted = prefs.getBool('termsAccepted');

    if (termsAccepted != true) {
      Get.offAllNamed('/terms');
    } else {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final String? selectedLanguage = prefs.getString('selected_language');

    if (selectedLanguage == null) {
      Get.offAllNamed('/language-settings');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.offAllNamed('/login');
    } else if (!user.emailVerified) {
      Get.offAllNamed('/verify-email');
    } else {
      Get.offAllNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/Icon-192.png'),
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Bem-vindo ao NetDrinks",
                        style: TextStyle(
                          color: Color.fromARGB(255, 204, 7, 17),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/Icon-192.png'),
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Descubra novos drinks",
                        style: TextStyle(
                          color: Color.fromARGB(255, 204, 7, 17),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/Icon-192.png'),
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Aproveite!",
                        style: TextStyle(
                          color: Color.fromARGB(255, 204, 7, 17),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
