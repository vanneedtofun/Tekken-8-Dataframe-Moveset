import 'package:flutter/material.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const TekkenMoveGuideApp());
}

class TekkenMoveGuideApp extends StatelessWidget {
  const TekkenMoveGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tekken Move Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF151515),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF252525),
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(color: Color(0xFF252525), elevation: 2),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF252525),
        ),
      ),
      home: const HomePage(),
    );
  }
}
