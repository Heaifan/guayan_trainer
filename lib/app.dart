import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class GuayanTrainerApp extends StatelessWidget {
  const GuayanTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '卦眼训练器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFAF0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6F5E),
          primary: const Color(0xFF2F6F5E),
          secondary: const Color(0xFFC0392B),
          surface: const Color(0xFFFFF4DC),
        ),
        fontFamily: 'sans',
      ),
      home: const HomePage(),
    );
  }
}
