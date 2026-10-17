import 'package:flutter/foundation.dart';
import '../data/product.dart';
import '../data/product_repository.dart';
import '../data/result.dart';

/// Разделяемое состояние каталога: список товаров + триада loading/data/error.
class ProductsModel extends ChangeNotifier {
  ProductsModel(this._repository); // простой DI: хранилище — в конструктор

  final ProductRepository _repository; // тип — ИНТЕРФЕЙС, а не mock

  static const _limit = 20; // размер страницы

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String? _search;
  String? _error;
  List<Product> _products = const [];

  bool get isLoading => _loading;
  bool get hasMore => _hasMore; // полная страница → видимо, есть ещё
  String? get search => _search;
  String? get error => _error;
  List<Product> get products => List.unmodifiable(_products);

  /// Товары с низким остатком — для badge в каталоге.
  int get lowStockCount => _products.where((p) => p.quantity < 10).length;

  /// Поиск идёт на сервере; retry (load() без аргумента) сохраняет фильтр.
  Future<void> load({String? search}) async {
    _search = search ?? _search;
    _page = 1;
    _loading = true;
    _error = null;
    notifyListeners(); // подписанные экраны входят в «грузится»
    await _fetch();
    _loading = false;
    notifyListeners(); // …и выходят: с данными или с ошибкой
  }

  /// Тихое обновление после операции — без spinner-а на весь экран.
  Future<void> refresh() async {
    await _fetch();
    notifyListeners();
  }

  Future<void> _fetch() async {
    switch (await _repository.fetchAll(limit: _limit, search: _search)) {
      case Ok(:final value):
        _products = value;
        _page = 1;
        _hasMore = value.length == _limit;
        _error = null;
      case Err(:final msg):
        _error = msg;
    }
  }

  /// Следующая страница. Вызывается из itemBuilder, в разгар build —
  /// поэтому _loadingMore ставится БЕЗ notifyListeners().
  Future<void> loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return; // guard от дублей
    _loadingMore = true;
    final result = await _repository.fetchAll(
        page: _page + 1, limit: _limit, search: _search);
    switch (result) {
      case Ok(:final value):
        _page += 1;
        _products = [..._products, ...value]; // страница приклеивается
        _hasMore = value.length == _limit;
      case Err():
        _hasMore = false; // хвост замолкает; pull «Повторить» — через load()
    }
    _loadingMore = false;
    notifyListeners();
  }


  Product? byId(int id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Product> inLocation(int locationId) =>
      _products.where((p) => p.locationId == locationId).toList();

  /// Мутация: null — успех, иначе сообщение об ошибке (как у validator).
  Future<String?> remove(int id) async {
    switch (await _repository.delete(id)) {
      case Ok():
        _products = _products.where((p) => p.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg; // состояние нетронуто — экран решает, что показать
    }
  }
}
