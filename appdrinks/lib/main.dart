import 'package:app_netdrinks/bindings/app_bindings.dart';
import 'package:app_netdrinks/bindings/search_binding.dart';
import 'package:app_netdrinks/firebase_options.dart';
import 'package:app_netdrinks/screens/cocktail_detail_screen.dart';
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

  // Configurar o GetIt
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
      locale: locale, // Define o locale inicial
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
        Locale('en', ''), // Inglês
        Locale('pt', ''), // Português
        Locale('es', ''), // Espanhol
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
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(
            name: '/language-settings',
            page: () => const LanguageSelectionScreen()),
        GetPage(
            name: '/terms',
            page: () => TermsOfServiceDialog(onAccepted: () {
                  if (true) {
                    Get.to(() => LoginScreen());
                  }
                }, onDeclined: () {
                  Get.back();
                })), // Adicionar esta linha
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(
          name: '/verify-email',
          page: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return LoginScreen();
            }
            return VerifyEmailScreen(user: user);
          },
        ),
        GetPage(
          name: '/home',
          page: () {
            final user = FirebaseAuth.instance.currentUser;
            final showFavorites = Get.parameters['showFavorites'] == 'true';
            if (user == null) {
              return LoginScreen();
            }
            return HomeScreen(
              user: user,
              showFavorites: showFavorites,
            );
          },
        ),
        GetPage(
          name: '/favorites',
          page: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return LoginScreen();
            }
            return HomeScreen(user: user, showFavorites: true);
          },
        ),
        GetPage(
          name: '/search',
          page: () => SearchScreen(),
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
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 204, 7, 17), // Vermelho Netflix
          brightness: Brightness.dark,
          primary: const Color.fromARGB(255, 204, 7, 17), // Vermelho Netflix
          secondary: const Color(0xFFFFFFFF), // Branco
          surface: const Color(0xFF000000), // Preto
          onPrimary: const Color(0xFFFFFFFF), // Branco
          onSecondary: const Color(0xFF000000), // Preto
          onSurface: const Color(0xFFFFFFFF), // Branco
        ),
        scaffoldBackgroundColor: const Color(0xFF000000), // Preto
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000), // Preto
          foregroundColor: Color.fromARGB(255, 204, 7, 17), // Vermelho Netflix
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF121212), // Preto mais claro
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFFFFFFF)), // Branco
          bodyMedium: TextStyle(color: Color(0xFFFFFFFF)), // Branco
          titleLarge: TextStyle(
              color: Color.fromARGB(255, 204, 7, 17)), // Vermelho Netflix
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

class InitialScreenState extends State<InitialScreen> {
  final bool termsAccepted = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.delayed(const Duration(seconds: 3), () {
      _checkTermsAccepted();
    });
  }

  Future<void> _checkTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? termsAccepted = prefs.getBool('termsAccepted');

    if (termsAccepted == true) {
      _navigateToNextScreen();
    } else {
      _showTermsOfServiceDialog();
    }
  }

  void _showTermsOfServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TermsOfServiceDialog(
          onAccepted: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('termsAccepted', true);
            _navigateToNextScreen();
          },
          onDeclined: () {
            Navigator.of(context).pop();
            // Lógica para lidar com a recusa dos termos
          },
        );
      },
    );
  }

  void _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final String? selectedLanguage = prefs.getString('selected_language');

    if (selectedLanguage == null) {
      Navigator.of(context).pushReplacementNamed('/language-settings');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else if (!user.emailVerified) {
      Navigator.of(context).pushReplacementNamed('/verify-email');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
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
                color: Colors.black, // Alterado para preto
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
