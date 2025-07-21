import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const PocketPalApp());
}

class PocketPalApp extends StatelessWidget {
  const PocketPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
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
            initialRoute: '/onboarding',
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/': (context) => const HomeScreen(),
              '/add-expense': (context) => const AddExpenseScreen(),
            },
          );
        },
      ),
    );
  }
}
