import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';
import 'http_utils.dart';

/// Складские операции. POST проводит операцию: меняет остаток/ячейку товара.
class Movements {
  Movements(this.db);
  final Database db;

  static const _types = ['receipt', 'shipment', 'transfer'];

  static Map<String, Object?> toJson(Row r) => {
        'id': r['id'],
        'productId': r['product_id'],
        'type': r['type'],
        'quantity': r['quantity'],
        'fromLocationId': r['from_location_id'],
        'toLocationId': r['to_location_id'],
        'userId': r['user_id'],
        'note': r['note'],
        'createdAt': r['created_at'],
      };

  Router get router => Router()
    ..get('/', _list)
    ..post('/', _create)
    ..get('/<id|[0-9]+>', _get)
    ..delete('/<id|[0-9]+>', _delete);

  Response _list(Request req) {
    final p = paging(req);
    final q = req.url.queryParameters;
    final where = <String>[];
    final args = <Object?>[];
    if (_types.contains(q['type'])) {
      where.add('type = ?');
      args.add(q['type']);
    }
    final product = int.tryParse(q['productId'] ?? '');
    if (product != null) {
      where.add('product_id = ?');
      args.add(product);
    }
    final w = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final total = db
        .select('SELECT COUNT(*) AS c FROM stock_movements $w', args)
        .first['c'] as int;
    final rows = db.select(
        'SELECT * FROM stock_movements $w ORDER BY created_at DESC, id DESC '
        'LIMIT ? OFFSET ?',
        [...args, p.limit, p.offset]);
    return envelope(rows.map(toJson).toList(), p.page, p.limit, total);
  }

  Map<String, Object?>? _find(Object id) {
    final rows = db.select(
        'SELECT * FROM stock_movements WHERE id = ?', [int.parse('$id')]);
    return rows.isEmpty ? null : toJson(rows.first);
  }

  Response _get(Request req, String id) {
    final m = _find(id);
    return m == null ? notFound() : jsonOk(m);
  }

  bool _locationExists(Object? id) =>
      id is int &&
      db.select('SELECT id FROM locations WHERE id = ?', [id]).isNotEmpty;

  Future<Response> _create(Request req) async {
    final b = await readJson(req);
    if (b == null) return validation('Body must be a JSON object');
    final type = b['type'];
    final qty = b['quantity'];
    final productId = b['productId'];
    final from = b['fromLocationId'];
    final to = b['toLocationId'];
    if (!_types.contains(type)) return validation('Unknown type');
    if (qty is! int || qty <= 0) return validation('quantity must be > 0');
    if (productId is! int) return validation('productId is required');
    final products =
        db.select('SELECT * FROM products WHERE id = ?', [productId]);
    if (products.isEmpty) return validation('productId does not exist');
    final stock = products.first['quantity'] as int;
    if (type != 'receipt' && !_locationExists(from)) {
      return validation('fromLocationId is required');
    }
    if (type != 'shipment' && !_locationExists(to)) {
      return validation('toLocationId is required');
    }
    if (type != 'receipt' && qty > stock) {
      return validation('Not enough stock');
    }

    // проведение операции — в одной транзакции с записью в журнал
    db.execute('BEGIN');
    switch (type) {
      case 'receipt':
        db.execute(
            'UPDATE products SET quantity = quantity + ?, location_id = ? WHERE id = ?',
            [qty, to, productId]);
      case 'shipment':
        db.execute('UPDATE products SET quantity = quantity - ? WHERE id = ?',
            [qty, productId]);
      case 'transfer':
        db.execute('UPDATE products SET location_id = ? WHERE id = ?',
            [to, productId]);
    }
    db.execute(
        'INSERT INTO stock_movements (product_id, type, quantity, from_location_id, '
        'to_location_id, user_id, note, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [productId, type, qty, type == 'receipt' ? null : from,
         type == 'shipment' ? null : to, userIdOf(req),
         (b['note'] as String? ?? '').trim(),
         DateTime.now().toUtc().toIso8601String()]);
    final id = db.lastInsertRowId;
    db.execute('COMMIT');
    return jsonOk(_find(id), status: 201);
  }

  Response _delete(Request req, String id) {
    if (_find(id) == null) return notFound();
    db.execute('DELETE FROM stock_movements WHERE id = ?', [int.parse(id)]);
    return Response(204);
  }
}
