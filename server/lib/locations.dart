import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';
import 'http_utils.dart';

/// CRUD ячеек. В ответе — посчитанные used (сумма остатков) и itemCount.
class Locations {
  Locations(this.db);
  final Database db;

  static const _select = '''
    SELECT l.*, COALESCE(SUM(p.quantity), 0) AS used, COUNT(p.id) AS item_count
    FROM locations l LEFT JOIN products p ON p.location_id = l.id
  ''';

  static Map<String, Object?> toJson(Row r) => {
        'id': r['id'],
        'code': r['code'],
        'zone': r['zone'],
        'capacity': r['capacity'],
        'used': r['used'],
        'itemCount': r['item_count'],
      };

  Router get router => Router()
    ..get('/', _list)
    ..post('/', _create)
    ..get('/<id|[0-9]+>', _get)
    ..put('/<id|[0-9]+>', _update)
    ..delete('/<id|[0-9]+>', _delete);

  Response _list(Request req) {
    final p = paging(req);
    final search = req.url.queryParameters['search'] ?? '';
    final w = search.isEmpty ? '' : 'WHERE l.code LIKE ?';
    final args = search.isEmpty ? <Object?>[] : ['%$search%'];
    final total = db
        .select('SELECT COUNT(*) AS c FROM locations l $w', args)
        .first['c'] as int;
    final rows = db.select(
        '$_select $w GROUP BY l.id ORDER BY l.code LIMIT ? OFFSET ?',
        [...args, p.limit, p.offset]);
    return envelope(rows.map(toJson).toList(), p.page, p.limit, total);
  }

  Map<String, Object?>? _find(Object id) {
    final rows = db.select(
        '$_select WHERE l.id = ? GROUP BY l.id', [int.parse('$id')]);
    return rows.isEmpty ? null : toJson(rows.first);
  }

  Response _get(Request req, String id) {
    final l = _find(id);
    return l == null ? notFound() : jsonOk(l);
  }

  String? _check(Map<String, dynamic> b) {
    for (final f in ['code', 'zone']) {
      final v = b[f];
      if (v is! String || v.trim().isEmpty) return '$f is required';
    }
    final cap = b['capacity'];
    if (cap is! int || cap <= 0) return 'capacity must be a positive int';
    return null;
  }

  Future<Response> _create(Request req) async {
    final b = await readJson(req);
    if (b == null) return validation('Body must be a JSON object');
    final err = _check(b);
    if (err != null) return validation(err);
    try {
      db.execute('INSERT INTO locations (code, zone, capacity) VALUES (?, ?, ?)',
          [b['code'], b['zone'], b['capacity']]);
    } on SqliteException {
      return validation('code must be unique');
    }
    return jsonOk(_find(db.lastInsertRowId), status: 201);
  }

  Future<Response> _update(Request req, String id) async {
    if (_find(id) == null) return notFound();
    final b = await readJson(req);
    if (b == null) return validation('Body must be a JSON object');
    final err = _check(b);
    if (err != null) return validation(err);
    try {
      db.execute(
          'UPDATE locations SET code = ?, zone = ?, capacity = ? WHERE id = ?',
          [b['code'], b['zone'], b['capacity'], int.parse(id)]);
    } on SqliteException {
      return validation('code must be unique');
    }
    return jsonOk(_find(id));
  }

  Response _delete(Request req, String id) {
    if (_find(id) == null) return notFound();
    try {
      db.execute('DELETE FROM locations WHERE id = ?', [int.parse(id)]);
    } on SqliteException {
      return validation('Location is not empty or used in history');
    }
    return Response(204);
  }
}
