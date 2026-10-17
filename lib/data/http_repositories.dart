import 'api_client.dart';
import 'app_user.dart';
import 'location.dart';
import 'location_repository.dart';
import 'movement_repository.dart';
import 'product.dart';
import 'product_repository.dart';
import 'result.dart';
import 'stock_movement.dart';
import 'user_repository.dart';

/// Вторая реализация интерфейсов L4 — поверх REST API сервера.
class HttpProductRepository implements ProductRepository {
  HttpProductRepository(this._api);
  final ApiClient _api;

  @override
  Future<Result<List<Product>>> fetchAll(
          {int page = 1, int limit = 20, String? search}) =>
      _api.send('GET', '/products',
          query: {
            'page': '$page',
            'limit': '$limit',
            if (search != null && search.isNotEmpty) 'search': search,
          },
          parse: (json) => itemsOf(json, Product.fromJson));


  @override
  Future<Result<Product>> fetchById(int id) => _api.send('GET', '/products/$id',
      parse: (json) => Product.fromJson(json as Map<String, dynamic>));

  @override
  Future<Result<Product>> create(Product product) => _api.send(
      'POST', '/products',
      body: product.toJson(),
      okStatus: 201, // id даёт сервер
      parse: (json) => Product.fromJson(json as Map<String, dynamic>));

  @override
  Future<Result<Product>> update(Product product) => _api.send(
      'PUT', '/products/${product.id}',
      body: product.toJson(),
      parse: (json) => Product.fromJson(json as Map<String, dynamic>));

  @override
  Future<Result<void>> delete(int id) => _api.send('DELETE', '/products/$id',
      okStatus: 204, parse: (_) {}); // пустое тело — без jsonDecode
}

class HttpLocationRepository implements LocationRepository {
  HttpLocationRepository(this._api);
  final ApiClient _api;

  @override
  Future<Result<List<Location>>> fetchAll() => _api.send('GET', '/locations',
      query: {'limit': '100'},
      parse: (json) => itemsOf(json, Location.fromJson));

  @override
  Future<Result<Location>> fetchById(int id) =>
      _api.send('GET', '/locations/$id',
          parse: (json) => Location.fromJson(json as Map<String, dynamic>));
}

class HttpMovementRepository implements MovementRepository {
  HttpMovementRepository(this._api);
  final ApiClient _api;

  @override
  Future<Result<List<StockMovement>>> fetchAll() =>
      _api.send('GET', '/stock-movements',
          query: {'limit': '100'},
          parse: (json) => itemsOf(json, StockMovement.fromJson));

  @override
  Future<Result<StockMovement>> create(StockMovement movement) => _api.send(
      'POST', '/stock-movements',
      body: movement.toJson(),
      okStatus: 201,
      parse: (json) => StockMovement.fromJson(json as Map<String, dynamic>));

  @override
  Future<Result<void>> delete(int id) => _api.send(
      'DELETE', '/stock-movements/$id',
      okStatus: 204, parse: (_) {});
}

class HttpUserRepository implements UserRepository {
  HttpUserRepository(this._api);
  final ApiClient _api;

  @override
  Future<Result<AppUser>> fetchMe() => _api.send('GET', '/auth/me',
      parse: (json) => AppUser.fromJson(json as Map<String, dynamic>));
}
