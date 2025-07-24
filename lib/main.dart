import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'providers/expense_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/reports_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context != null && message.notification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.notification!.title ?? 'Notification')),
      );
    }
  });
  // Log app open event
  analytics.logAppOpen();

  // Determine initial route
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
  final loggedIn = prefs.getBool('loggedIn') ?? false;
  String initialRoute = '/onboarding'; // default fallback
  if (loggedIn) {
    initialRoute = '/';
  } else if (onboardingComplete) {
    initialRoute = '/login';
  }

  runApp(PocketPalApp(initialRoute: initialRoute));
}

class PocketPalApp extends StatelessWidget {
  final String initialRoute;
  const PocketPalApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = ExpenseProvider();
        provider.loadBudgetFromFirestore();
        provider.loadExpensesFromFirestore();
        return provider;
      },
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'PocketPal',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              colorSchemeSeed: Colors.indigo,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              colorSchemeSeed: Colors.indigo,
            ),
            initialRoute: initialRoute,
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/': (context) => const HomeScreen(),
              '/add-expense': (context) => const AddExpenseScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/budget': (context) => const BudgetScreen(),
              '/reports': (context) => const ReportsScreen(),
            },
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            builder: (context, child) => Stack(
              children: [
                child!,
                if (provider.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
