import 'package:flutter_test/flutter_test.dart';
import 'package:stock_pilot/main.dart';

void main() {
  testWidgets('Открывается экран входа', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('StockPilot'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
  });
}
