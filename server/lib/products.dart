import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';
import 'http_utils.dart';

/// CRUD товаров — по образцу notes: список с пагинацией/поиском,
/// создание с валидацией (400), get/put/delete с 404.
class Products {
  Products(this.db);
  final Database db;

  static Map<String, Object?> toJson(Row r) => {
        'id': r['id'],
        'sku': r['sku'],
        'name': r['name'],
        'category': r['category'],
        'unit': r['unit'],
        'quantity': r['quantity'],
        'locationId': r['location_id'],
        'imageUrl': r['image_url'],
      };

  Router get router => Router()
    ..get('/', _list)
    ..post('/', _create)
    ..get('/<id|[0-9]+>', _get)
    ..put('/<id|[0-9]+>', _update)
    ..delete('/<id|[0-9]+>', _delete)
    ..put('/<id|[0-9]+>/location', _place);

  Response _list(Request req) {
    final p = paging(req);
    final q = req.url.queryParameters;
    final where = <String>[];
    final args = <Object?>[];
    final search = q['search'] ?? q['q'];
    if (search != null && search.isNotEmpty) {
      where.add('(name LIKE ? OR sku LIKE ?)');
      args.addAll(['%$search%', '%$search%']);
    }
    if ((q['category'] ?? '').isNotEmpty) {
      where.add('category = ?');
      args.add(q['category']);
    }
    final loc = int.tryParse(q['locationId'] ?? '');
    if (loc != null) {
      where.add('location_id = ?');
      args.add(loc);
    }
    final w = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final total =
        db.select('SELECT COUNT(*) AS c FROM products $w', args).first['c'] as int;
    final rows = db.select(
        'SELECT * FROM products $w ORDER BY id LIMIT ? OFFSET ?',
        [...args, p.limit, p.offset]);
    return envelope(rows.map(toJson).toList(), p.page, p.limit, total);
  }

  Map<String, Object?>? _find(Object id) {
    final rows = db.select('SELECT * FROM products WHERE id = ?', [int.parse('$id')]);
    return rows.isEmpty ? null : toJson(rows.first);
  }

  Response _get(Request req, String id) {
    final p = _find(id);
    return p == null ? notFound() : jsonOk(p);
  }

  /// Проверка полей тела; null — всё хорошо.
  String? _check(Map<String, dynamic> b) {
    for (final f in ['sku', 'name', 'category', 'unit']) {
      final v = b[f];
      if (v is! String || v.trim().isEmpty) return '$f is required';
    }
    final qty = b['quantity'] ?? 0;
    if (qty is! int || qty < 0) return 'quantity must be a non-negative int';
    final loc = b['locationId'];
    if (loc != null &&
        (loc is! int ||
            db.select('SELECT id FROM locations WHERE id = ?', [loc]).isEmpty)) {
      return 'locationId does not exist';
    }
    return null;
  }

  Future<Response> _create(Request req) async {
    final b = await readJson(req);
    if (b == null) return validation('Body must be a JSON object');
    final err = _check(b);
    if (err != null) return validation(err);
    try {
      db.execute(
          'INSERT INTO products (sku, name, category, unit, quantity, location_id, image_url) '
          'VALUES (?, ?, ?, ?, ?, ?, ?)',
          [b['sku'], b['name'], b['category'], b['unit'], b['quantity'] ?? 0,
           b['locationId'], b['imageUrl'] ?? '']);
    } on SqliteException {
      return validation('sku must be unique');
    }
    return jsonOk(_find(db.lastInsertRowId), status: 201); // id дал сервер
  }

  Future<Response> _update(Request req, String id) async {
    if (_find(id) == null) return notFound();
    final b = await readJson(req);
    if (b == null) return validation('Body must be a JSON object');
    final err = _check(b);
    if (err != null) return validation(err);
    try {
      db.execute(
          'UPDATE products SET sku = ?, name = ?, category = ?, unit = ?, '
          'quantity = ?, location_id = ?, image_url = ? WHERE id = ?',
          [b['sku'], b['name'], b['category'], b['unit'], b['quantity'] ?? 0,
           b['locationId'], b['imageUrl'] ?? '', int.parse(id)]);
    } on SqliteException {
      return validation('sku must be unique');
    }
    return jsonOk(_find(id));
  }

  Response _delete(Request req, String id) {
    if (_find(id) == null) return notFound();
    db.execute('DELETE FROM products WHERE id = ?', [int.parse(id)]);
    return Response(204);
  }

  /// PUT /products/{id}/location {"locationId": 3} — разместить в ячейку.
  Future<Response> _place(Request req, String id) async {
    if (_find(id) == null) return notFound();
    final b = await readJson(req);
    final loc = b?['locationId'];
    if (loc is! int ||
        db.select('SELECT id FROM locations WHERE id = ?', [loc]).isEmpty) {
      return validation('locationId does not exist');
    }
    db.execute('UPDATE products SET location_id = ? WHERE id = ?',
        [loc, int.parse(id)]);
    return jsonOk(_find(id));
  }
}

