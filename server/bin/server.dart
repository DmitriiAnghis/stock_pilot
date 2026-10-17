import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:stock_pilot_server/auth.dart';
import 'package:stock_pilot_server/db.dart';
import 'package:stock_pilot_server/http_utils.dart';
import 'package:stock_pilot_server/locations.dart';
import 'package:stock_pilot_server/movements.dart';
import 'package:stock_pilot_server/products.dart';

/// Открытый CORS — лабораторная конфигурация.
Middleware _cors() => (inner) => (req) async {
      const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Authorization, Content-Type',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      };
      if (req.method == 'OPTIONS') return Response.ok(null, headers: headers);
      final res = await inner(req);
      return res.change(headers: headers);
    };

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final secret = Platform.environment['JWT_SECRET'] ?? 'dev-secret-change-me';
  final db = openDb(Platform.environment['DB_PATH'] ?? 'app.db');
  final auth = Auth(db, secret);

  // всё, что ниже, — только с валидным token-ом
  final protected = Router()
    ..get('/auth/me', auth.me)
    ..mount('/products', Products(db).router.call)
    ..mount('/locations', Locations(db).router.call)
    ..mount('/stock-movements', Movements(db).router.call);

  final app = Router(notFoundHandler: (_) => notFound())
    ..get('/health', (Request _) => jsonOk({'status': 'ok'}))
    ..mount('/auth', auth.router.call)
    ..mount('/', const Pipeline().addMiddleware(auth.middleware).addHandler(protected.call));

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(app.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('StockPilot API: http://localhost:${server.port}');
}
