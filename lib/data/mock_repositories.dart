import 'app_user.dart';
import 'location.dart';
import 'location_repository.dart';
import 'mock_data.dart';
import 'movement_repository.dart';
import 'product.dart';
import 'product_repository.dart';
import 'result.dart';
import 'stock_movement.dart';
import 'user_repository.dart';

/// Память mock-хранилища, общая для всех mock-репозиториев,
/// с повадками сети: задержка и переключаемая авария.
class MockBackend {
  final List<Product> products = List.of(mockProducts); // seed
  final List<Location> locations = List.of(mockLocations);
  final List<StockMovement> movements = List.of(mockMovements);
  int nextId = 1000; // выше любого id из seed-а

  bool simulateError = false; // авария: включена → любой вызов проваливается

  static const _latency = Duration(milliseconds: 800);
  static const errNetwork = 'Сервер не отвечает — повторите попытку';

  /// Пролог каждого метода: задержка + авария. null — можно продолжать.
  Future<String?> prologue() async {
    await Future.delayed(_latency); // сеть не отвечает мгновенно
    return simulateError ? errNetwork : null;
  }

  /// Ячейка с посчитанной загруженностью.
  Location withUsage(Location l) {
    final inside = products.where((p) => p.locationId == l.id);
    return l.copyWith(
        used: inside.fold<int>(0, (sum, p) => sum + p.quantity),
        itemCount: inside.length);
  }
}

class MockProductRepository implements ProductRepository {
  MockProductRepository(this._db);
  final MockBackend _db;

  @override
  Future<Result<List<Product>>> fetchAll() async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    return Ok(List.of(_db.products)); // копия — внутренность не отдаётся
  }

  @override
  Future<Result<Product>> fetchById(int id) async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    final i = _db.products.indexWhere((p) => p.id == id);
    if (i < 0) return const Err('Товар не существует'); // «404» mock-а
    return Ok(_db.products[i]);
  }

  @override
  Future<Result<Product>> create(Product product) async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    final created = product.copyWith(id: _db.nextId++); // id даёт хранилище
    _db.products.add(created);
    return Ok(created);
  }

  @override
  Future<Result<Product>> update(Product product) async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    final i = _db.products.indexWhere((p) => p.id == product.id);
    if (i < 0) return const Err('Товар не существует');
    _db.products[i] = product;
    return Ok(product);
  }

  @override
  Future<Result<void>> delete(int id) async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    final before = _db.products.length;
    _db.products.removeWhere((p) => p.id == id);
    if (_db.products.length == before) return const Err('Товар не существует');
    return const Ok(null); // «удалил, отдать нечего»
  }
}

class MockLocationRepository implements LocationRepository {
  MockLocationRepository(this._db);
  final MockBackend _db;

  @override
  Future<Result<List<Location>>> fetchAll() async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    return Ok(_db.locations.map(_db.withUsage).toList());
  }

  @override
  Future<Result<Location>> fetchById(int id) async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    final i = _db.locations.indexWhere((l) => l.id == id);
    if (i < 0) return const Err('Ячейка не существует');
    return Ok(_db.withUsage(_db.locations[i]));
  }
}

class MockMovementRepository implements MovementRepository {
  MockMovementRepository(this._db);
  final MockBackend _db;

  @override
  Future<Result<List<StockMovement>>> fetchAll() async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    final list = List.of(_db.movements)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // новые сверху
    return Ok(list);
  }

  @override
  Future<Result<StockMovement>> create(StockMovement m) async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    final i = _db.products.indexWhere((p) => p.id == m.productId);
    if (i < 0) return const Err('Товар не существует');
    final p = _db.products[i];
    // операция меняет остаток и ячейку товара — как сделает сервер на L5
    switch (m.type) {
      case MovementType.receipt:
        _db.products[i] = p.copyWith(
            quantity: p.quantity + m.quantity, locationId: m.toLocationId);
      case MovementType.shipment:
        if (m.quantity > p.quantity) return const Err('Недостаточно товара');
        _db.products[i] = p.copyWith(quantity: p.quantity - m.quantity);
      case MovementType.transfer:
        _db.products[i] = p.copyWith(locationId: m.toLocationId);
    }
    final created = m.copyWith(id: _db.nextId++);
    _db.movements.add(created);
    return Ok(created);
  }

  @override
  Future<Result<void>> delete(int id) async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    final before = _db.movements.length;
    _db.movements.removeWhere((m) => m.id == id);
    if (_db.movements.length == before) {
      return const Err('Операция не существует');
    }
    return const Ok(null);
  }
}

class MockUserRepository implements UserRepository {
  MockUserRepository(this._db);
  final MockBackend _db;

  @override
  Future<Result<AppUser>> fetchMe() async {
    final err = await _db.prologue();
    if (err != null) return Err(err);
    return const Ok(mockUser);
  }
}
