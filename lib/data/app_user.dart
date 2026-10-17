/// Текущий пользователь (для профиля).
class AppUser {
  final int id;
  final String name;
  final String email;

  const AppUser(this.id, this.name, this.email);

  factory AppUser.fromJson(Map<String, dynamic> j) =>
      AppUser(j['id'] as int, j['name'] as String, j['email'] as String);


  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }
}
