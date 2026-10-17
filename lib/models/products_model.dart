import 'package:flutter/foundation.dart';
import '../data/product.dart';
import '../data/product_repository.dart';
import '../data/result.dart';

/// Разделяемое состояние каталога: список товаров + триада loading/data/error.
class ProductsModel extends ChangeNotifier {
  ProductsModel(this._repository); // простой DI: хранилище — в конструктор

  final ProductRepository _repository; // тип — ИНТЕРФЕЙС, а не mock

  bool _loading = false;
  String? _error;
  List<Product> _products = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<Product> get products => List.unmodifiable(_products);

  /// Товары с низким остатком — для badge в каталоге.
  int get lowStockCount => _products.where((p) => p.quantity < 10).length;

  Future<void> load() async {
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
    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _products = value;
        _error = null;
      case Err(:final msg):
        _error = msg;
    }
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
