import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stock_pilot/data/auth_api.dart';
import 'package:stock_pilot/main.dart';
import 'package:stock_pilot/models/locations_model.dart';
import 'package:stock_pilot/models/movements_model.dart';
import 'package:stock_pilot/models/products_model.dart';
import 'package:stock_pilot/models/profile_model.dart';
import 'package:stock_pilot/router.dart';

import 'fakes.dart';

Widget _app(FakeServer s) => MultiProvider(
  providers: [
    Provider<AuthApi>(create: (_) => FakeAuthApi()),
    ChangeNotifierProvider(
      create: (_) => ProductsModel(FakeProductRepository(s)),
    ),
    ChangeNotifierProvider(
      create: (_) => LocationsModel(FakeLocationRepository(s)),
    ),
    ChangeNotifierProvider(
      create: (_) => MovementsModel(FakeMovementRepository(s)),
    ),
    ChangeNotifierProvider(create: (_) => ProfileModel(FakeUserRepository(s))),
  ],
  child: const MyApp(),
);

Future<void> _login(WidgetTester tester, String password) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'ana@test.md');
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Войти'));
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  router = GoRouter(initialLocation: '/login', routes: appRoutes);
  setUp(() => router.go('/login')); // router глобальный — возвращаем на старт

  testWidgets('Вход: ошибки валидации, ошибка сервера, затем каталог', (
    tester,
  ) async {
    await tester.pumpWidget(_app(FakeServer()));
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Введите e-mail'), findsOneWidget);
    expect(find.text('Введите пароль'), findsOneWidget);

    await _login(tester, 'wrong12');
    expect(find.text('Неверный email или пароль'), findsOneWidget);

    await _login(tester, 'parola123');
    expect(find.text('Каталог товаров'), findsOneWidget);
    expect(
      find.text('Показано товаров: 20'),
      findsOneWidget,
    ); // первая страница
  });

  testWidgets('Сервер недоступен → экран ошибки, retry возвращает данные', (
    tester,
  ) async {
    final server = FakeServer()..down = true;
    await tester.pumpWidget(_app(server));
    await _login(tester, 'parola123');
    expect(find.text('Повторить'), findsOneWidget);

    server.down = false;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.textContaining('Показано товаров'), findsOneWidget);
  });

  testWidgets('Пагинация: хвост списка догружает страницу; поиск на сервере', (
    tester,
  ) async {
    await tester.pumpWidget(_app(FakeServer()));
    await _login(tester, 'parola123');
    expect(find.text('Показано товаров: 20'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Товар №25'),
      find.byType(ListView).last,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Показано товаров: 25'), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'Товар №2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // «Товар №2» и «Товар №20…25» — ответ сервера, а не локальный фильтр
    expect(find.text('Показано товаров: 7'), findsOneWidget);
  });
}
