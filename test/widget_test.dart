import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stock_pilot/data/mock_repositories.dart';
import 'package:stock_pilot/main.dart';
import 'package:stock_pilot/models/locations_model.dart';
import 'package:stock_pilot/models/movements_model.dart';
import 'package:stock_pilot/models/products_model.dart';
import 'package:stock_pilot/models/profile_model.dart';
import 'package:stock_pilot/router.dart';

Widget _app(MockBackend backend) => MultiProvider(
      providers: [
        Provider<MockBackend>.value(value: backend),
        ChangeNotifierProvider(
            create: (_) => ProductsModel(MockProductRepository(backend))..load()),
        ChangeNotifierProvider(
            create: (_) =>
                LocationsModel(MockLocationRepository(backend))..load()),
        ChangeNotifierProvider(
            create: (_) =>
                MovementsModel(MockMovementRepository(backend))..load()),
        ChangeNotifierProvider(
            create: (_) => ProfileModel(MockUserRepository(backend))..load()),
      ],
      child: const MyApp(),
    );

void main() {
  testWidgets('Вход: ошибки валидации, затем каталог грузится из repository',
      (tester) async {
    await tester.pumpWidget(_app(MockBackend()));
    expect(find.text('StockPilot'), findsOneWidget);

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Введите e-mail'), findsOneWidget);
    expect(find.text('Введите пароль'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ana@test.md');
    await tester.enterText(find.byType(TextFormField).at(1), 'parola123');
    await tester.tap(find.text('Войти'));
    await tester.pump();
    expect(find.text('Каталог товаров'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget); // грузится
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Найдено товаров: 9'), findsOneWidget); // данные
  });

  testWidgets('Авария mock-а показывает экран ошибки с «Повторить»',
      (tester) async {
    router.go('/login'); // router глобальный — возвращаем его на старт
    final backend = MockBackend()..simulateError = true;

    await tester.pumpWidget(_app(backend));
    await tester.enterText(find.byType(TextFormField).at(0), 'ana@test.md');
    await tester.enterText(find.byType(TextFormField).at(1), 'parola123');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Повторить'), findsOneWidget);

    backend.simulateError = false;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Найдено товаров: 9'), findsOneWidget);
  });
}
