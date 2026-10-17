import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_pilot/main.dart';

void main() {
  testWidgets('Вход: ошибки валидации, затем переход в каталог',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('StockPilot'), findsOneWidget);

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Введите e-mail'), findsOneWidget);
    expect(find.text('Введите пароль'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ana@test.md');
    await tester.enterText(find.byType(TextFormField).at(1), 'parola123');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Каталог товаров'), findsOneWidget);
  });
}
