// Фейковые реализации интерфейсов для widget-тестов (без сети).
import 'package:stock_pilot/data/app_user.dart';
import 'package:stock_pilot/data/auth_api.dart';
import 'package:stock_pilot/data/location.dart';
import 'package:stock_pilot/data/location_repository.dart';
import 'package:stock_pilot/data/movement_repository.dart';
import 'package:stock_pilot/data/product.dart';
import 'package:stock_pilot/data/product_repository.dart';
import 'package:stock_pilot/data/result.dart';
import 'package:stock_pilot/data/stock_movement.dart';
import 'package:stock_pilot/data/token_store.dart';
import 'package:stock_pilot/data/user_repository.dart';

class FakeServer {
  bool down = false;
  final products = List.generate(
      25,
      (i) => Product(i + 1, 'SKU-${1000 + i}', 'Товар №${i + 1}', 'Упаковка',
          'шт', 5 + i, 1, ''));

  Future<String?> call() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return down ? 'Нет сети — повторите попытку' : null;
  }
}

class FakeAuthApi extends AuthApi {
  FakeAuthApi() : super('', TokenStore());

  @override
  Future<Result<void>> login(String email, String password) async =>
      password == 'parola123'
          ? const Ok(null)
          : const Err('Неверный email или пароль');
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.s);
  final FakeServer s;

  @override
  Future<Result<List<Product>>> fetchAll(
      {int page = 1, int limit = 20, String? search}) async {
    final err = await s();
    if (err != null) return Err(err);
    final all = s.products
        .where((p) => search == null || p.name.contains(search))
        .toList();
    return Ok(all.skip((page - 1) * limit).take(limit).toList());
  }

  @override
  Future<Result<Product>> fetchById(int id) async =>
      Ok(s.products.firstWhere((p) => p.id == id));

  @override
  Future<Result<Product>> create(Product product) async => Ok(product);

  @override
  Future<Result<Product>> update(Product product) async => Ok(product);

  @override
  Future<Result<void>> delete(int id) async {
    s.products.removeWhere((p) => p.id == id);
    return const Ok(null);
  }
}

class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository(this.s);
  final FakeServer s;
  static const _l = Location(1, 'A-01-01', 'Зона A', 400);

  @override
  Future<Result<List<Location>>> fetchAll() async {
    final err = await s();
    return err != null ? Err(err) : const Ok([_l]);
  }

  @override
  Future<Result<Location>> fetchById(int id) async => const Ok(_l);
}

class FakeMovementRepository implements MovementRepository {
  FakeMovementRepository(this.s);
  final FakeServer s;

  @override
  Future<Result<List<StockMovement>>> fetchAll() async {
    final err = await s();
    return err != null ? Err(err) : const Ok([]);
  }

  @override
  Future<Result<StockMovement>> create(StockMovement m) async => Ok(m);

  @override
  Future<Result<void>> delete(int id) async => const Ok(null);
}

class FakeUserRepository implements UserRepository {
  FakeUserRepository(this.s);
  final FakeServer s;

  @override
  Future<Result<AppUser>> fetchMe() async =>
      const Ok(AppUser(1, 'Ana Test', 'ana@test.md'));
}
