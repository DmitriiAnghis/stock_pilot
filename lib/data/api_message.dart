import 'dart:convert';
import 'package:http/http.dart' as http;

/// Вскрывает конверт ошибки {"error":{"code","message"}} и переводит code.
/// Английский message на экран не попадает.
String apiMessage(http.Response res) {
  try {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final code = (body['error'] as Map<String, dynamic>)['code'] as String;
    return switch (code) {
      'VALIDATION_ERROR' => 'Отправленные данные недействительны',
      'UNAUTHORIZED' => 'Неверный email или пароль',
      'EMAIL_TAKEN' => 'Аккаунт с этим email уже существует',
      'NOT_FOUND' => 'Запись не существует',
      _ => 'Ошибка сервера ($code)',
    };
  } on FormatException {
    return 'Ошибка сервера (${res.statusCode})'; // тело вне контракта
  } on TypeError {
    return 'Ошибка сервера (${res.statusCode})';
  }
}
