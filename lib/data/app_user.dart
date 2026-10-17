/// Текущий пользователь (для профиля).
class AppUser {
  final int id;
  final String name;
  final String email;

  const AppUser(this.id, this.name, this.email);

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }
}
