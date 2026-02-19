import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Texas Hold\'em Poker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1a237e),
        scaffoldBackgroundColor: const Color(0xFF0d1b2a),
        cardColor: const Color(0xFF1b263b),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4a5bc0),
          secondary: const Color(0xFFff6b35),
          surface: const Color(0xFF1b263b),
          background: const Color(0xFF0d1b2a),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a237e),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4a5bc0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
