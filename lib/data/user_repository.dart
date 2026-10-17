import 'app_user.dart';
import 'result.dart';

/// Контракт: данные текущего пользователя.
abstract class UserRepository {
  Future<Result<AppUser>> fetchMe();
}
