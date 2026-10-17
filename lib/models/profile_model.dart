import 'package:flutter/foundation.dart';
import '../data/app_user.dart';
import '../data/result.dart';
import '../data/user_repository.dart';

/// Состояние профиля: текущий пользователь.
class ProfileModel extends ChangeNotifier {
  ProfileModel(this._repository);

  final UserRepository _repository;

  bool _loading = false;
  String? _error;
  AppUser? _user;

  bool get isLoading => _loading;
  String? get error => _error;
  AppUser? get user => _user;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    switch (await _repository.fetchMe()) {
      case Ok(:final value):
        _user = value;
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }
}
