import 'package:flutter/foundation.dart';
import '../data/location.dart';
import '../data/location_repository.dart';
import '../data/result.dart';

/// Разделяемое состояние: складские ячейки с загруженностью.
class LocationsModel extends ChangeNotifier {
  LocationsModel(this._repository);

  final LocationRepository _repository;

  bool _loading = false;
  String? _error;
  List<Location> _locations = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<Location> get locations => List.unmodifiable(_locations);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    await _fetch();
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _fetch();
    notifyListeners();
  }

  Future<void> _fetch() async {
    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _locations = value;
        _error = null;
      case Err(:final msg):
        _error = msg;
    }
  }

  Location? byId(int? id) {
    for (final l in _locations) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// Код ячейки или «—», если ячейка неизвестна.
  String codeOf(int? id) => byId(id)?.code ?? '—';
}
