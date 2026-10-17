import 'dart:convert';
import 'package:shelf/shelf.dart';

const _json = {'Content-Type': 'application/json; charset=utf-8'};

Response jsonOk(Object? body, {int status = 200}) =>
    Response(status, body: jsonEncode(body), headers: _json);

/// Единый конверт ошибки: {"error":{"code":"...","message":"..."}}
Response apiError(int status, String code, String message) => Response(
      status,
      body: jsonEncode({
        'error': {'code': code, 'message': message}
      }),
      headers: _json,
    );

Response validation(String message) =>
    apiError(400, 'VALIDATION_ERROR', message);
Response notFound() => apiError(404, 'NOT_FOUND', 'Resource not found');

/// Читает JSON-объект тела; null — тело не JSON-объект.
Future<Map<String, dynamic>?> readJson(Request req) async {
  try {
    final body = jsonDecode(await req.readAsString());
    return body is Map<String, dynamic> ? body : null;
  } on FormatException {
    return null;
  }
}

/// Пагинация из query: ?page=&limit= (limit 1..100, по умолчанию 20).
({int page, int limit, int offset}) paging(Request req) {
  final q = req.url.queryParameters;
  final page = (int.tryParse(q['page'] ?? '') ?? 1).clamp(1, 1 << 30);
  final limit = (int.tryParse(q['limit'] ?? '') ?? 20).clamp(1, 100);
  return (page: page, limit: limit, offset: (page - 1) * limit);
}

/// Пагинированный конверт списка.
Response envelope(List<Object?> items, int page, int limit, int total) =>
    jsonOk({'items': items, 'page': page, 'limit': limit, 'total': total});

int? userIdOf(Request req) => req.context['userId'] as int?;
