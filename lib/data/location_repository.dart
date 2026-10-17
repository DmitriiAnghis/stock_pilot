import 'location.dart';
import 'result.dart';

/// Контракт хранилища ячеек.
abstract class LocationRepository {
  Future<Result<List<Location>>> fetchAll();
  Future<Result<Location>> fetchById(int id);
}
