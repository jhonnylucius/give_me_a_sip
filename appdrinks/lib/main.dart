import 'package:app_netdrinks/adapters/cocktail_adapter.dart';
import 'package:app_netdrinks/bindings/app_bindings.dart';
import 'package:app_netdrinks/bindings/search_binding.dart';
import 'package:app_netdrinks/firebase_options.dart';
import 'package:app_netdrinks/models/cocktail.dart';
import 'package:app_netdrinks/screens/cocktail_detail_screen.dart';
import 'package:app_netdrinks/screens/home_screen.dart';
import 'package:app_netdrinks/screens/login_screen.dart';
import 'package:app_netdrinks/screens/search/search_results_screen.dart';
import 'package:app_netdrinks/screens/search/search_screen.dart';
import 'package:app_netdrinks/screens/verify_email_screen.dart';
import 'package:app_netdrinks/widgets/cocktail_card_widget.dart' as widget;
import 'package:app_netdrinks/widgets/terms_of_service_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(CocktailAdapter());
  await Hive.openBox<Cocktail>('cocktailBox');

  // Verificar salvos
  final prefs = await SharedPreferences.getInstance();
  prefs.getString('language');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      title: 'NetDrinks',
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
        GetPage(name: '/', page: () => const InitialScreen()),
        GetPage(
          name: '/home',
          page: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return LoginScreen();
            }
            return HomeScreen(user: user, showFavorites: false);
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
          name: '/verify-email',
          page: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return LoginScreen();
            }
            return VerifyEmailScreen(user: user);
          },
        ),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(
          name: '/cocktail',
          page: () => widget.CocktailCard(
            user: FirebaseAuth.instance.currentUser?.uid ?? '',
            cocktail: Cocktail(
              idDrink: '1',
              strDrink: 'Example Drink',
              strInstructions: 'Mix ingredients',
              ingredients: ['Ingredient1', 'Ingredient2'],
              measures: ['1 oz', '2 oz'],
            ),
          ),
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
    _checkTermsAccepted();
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

  void _navigateToNextScreen() {
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
                  color: const Color.fromARGB(255, 177, 11, 19),
                  child: Center(
                      child: Text(
                    " ",
                    style: TextStyle(color: Colors.white),
                  ))),
              Container(
                  color: const Color.fromARGB(255, 177, 11, 19),
                  child: Center(
                      child: Text(
                    " ",
                    style: TextStyle(color: Colors.white),
                  ))),
              Container(
                  color: const Color.fromARGB(255, 177, 11, 19),
                  child: Center(
                      child: Text(
                    " ",
                    style: TextStyle(color: Colors.white),
                  ))),
            ],
          ),
        ],
      ),
    );
  }
}
