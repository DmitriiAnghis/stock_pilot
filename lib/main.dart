import 'package:flutter/material.dart';
import 'router.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StockPilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Оранжевый — сигнальный цвет склада (жилеты, погрузчики, разметка).
        // Вся палитра выводится из одного seed-цвета.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF6C00),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      ),
      routerConfig: router, // навигацию принимает go_router; home: исчезает

    );
  }
}
