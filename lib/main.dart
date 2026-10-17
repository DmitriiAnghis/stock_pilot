import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/mock_repositories.dart';
import 'models/locations_model.dart';
import 'models/movements_model.dart';
import 'models/products_model.dart';
import 'models/profile_model.dart';
import 'router.dart';

/// Корень композиции: ЗДЕСЬ (и только здесь) выбирается источник данных.
void main() {
  final backend = MockBackend(); // на L5: http-реализации — и всё

  runApp(
    MultiProvider(
      providers: [
        // леса демонстрации аварии — исчезают на L5
        Provider<MockBackend>.value(value: backend),
        ChangeNotifierProvider(
          create: (_) => ProductsModel(MockProductRepository(backend))..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              LocationsModel(MockLocationRepository(backend))..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              MovementsModel(MockMovementRepository(backend))..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileModel(MockUserRepository(backend))..load(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

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
