import 'result.dart';
import 'stock_movement.dart';

/// Контракт хранилища складских операций (вторая пишущая сущность).
abstract class MovementRepository {
  Future<Result<List<StockMovement>>> fetchAll();
  Future<Result<StockMovement>> create(StockMovement movement);
  Future<Result<void>> delete(int id);
}
