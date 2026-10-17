import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';
import 'http_utils.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String _hash(String password, String salt) =>
    sha256.convert(utf8.encode('$salt:$password')).toString();

String _salt() {
  final r = Random.secure();
  return base64Url.encode(List.generate(16, (_) => r.nextInt(256)));
}

Map<String, Object?> _user(Row r) =>
    {'id': r['id'], 'email': r['email'], 'name': r['name']};

class Auth {
  Auth(this.db, this.secret);
  final Database db;
  final String secret;

  String _token(int userId) => JWT({'sub': userId})
      .sign(SecretKey(secret), expiresIn: const Duration(days: 7));

  Router get router => Router()
    ..post('/register', _register)
    ..post('/login', _login);

  Future<Response> _register(Request req) async {
    final b = await readJson(req);
    final email = (b?['email'] as String? ?? '').trim().toLowerCase();
    final password = b?['password'] as String? ?? '';
    final name = (b?['name'] as String? ?? '').trim();
    if (!_emailRe.hasMatch(email)) return validation('Invalid email');
    if (password.length < 6) return validation('Password too short');
    if (name.isEmpty) return validation('Name is required');
    if (db.select('SELECT id FROM users WHERE email = ?', [email]).isNotEmpty) {
      return apiError(409, 'EMAIL_TAKEN', 'Email already registered');
    }
    final salt = _salt();
    db.execute(
        'INSERT INTO users (email, name, password_hash, salt, created_at) '
        'VALUES (?, ?, ?, ?, ?)',
        [email, name, _hash(password, salt), salt,
         DateTime.now().toUtc().toIso8601String()]);
    final row =
        db.select('SELECT * FROM users WHERE id = ?', [db.lastInsertRowId]).first;
    return jsonOk({'token': _token(row['id'] as int), 'user': _user(row)},
        status: 201);
  }

  Future<Response> _login(Request req) async {
    final b = await readJson(req);
    final email = (b?['email'] as String? ?? '').trim().toLowerCase();
    final password = b?['password'] as String? ?? '';
    if (email.isEmpty || password.isEmpty) {
      return validation('Email and password are required');
    }
    final rows = db.select('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.isEmpty ||
        _hash(password, rows.first['salt'] as String) !=
            rows.first['password_hash']) {
      return apiError(401, 'UNAUTHORIZED', 'Invalid credentials');
    }
    final row = rows.first;
    return jsonOk({'token': _token(row['id'] as int), 'user': _user(row)});
  }

  /// GET /auth/me — текущий пользователь (под middleware).
  Response me(Request req) {
    final rows = db.select('SELECT * FROM users WHERE id = ?', [userIdOf(req)]);
    if (rows.isEmpty) return apiError(401, 'UNAUTHORIZED', 'User not found');
    return jsonOk(_user(rows.first));
  }

  /// Middleware: `Authorization: Bearer <jwt>` → req.context['userId'].
  Middleware get middleware => (inner) => (req) {
        final header = req.headers['authorization'] ?? '';
        if (!header.startsWith('Bearer ')) {
          return apiError(401, 'UNAUTHORIZED', 'Missing token');
        }
        try {
          final jwt = JWT.verify(header.substring(7), SecretKey(secret));
          final id = (jwt.payload as Map)['sub'] as int;
          return inner(req.change(context: {'userId': id}));
        } on JWTException {
          return apiError(401, 'UNAUTHORIZED', 'Invalid or expired token');
        }
      };
}
