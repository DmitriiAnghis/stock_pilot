/// Складская ячейка. used и itemCount считает хранилище (сумма остатков
/// и число позиций в ячейке) — экран их только показывает.
class Location {
  final int id;
  final String code;
  final String zone;
  final int capacity;
  final int used;
  final int itemCount;

  const Location(this.id, this.code, this.zone, this.capacity,
      {this.used = 0, this.itemCount = 0});

  factory Location.fromJson(Map<String, dynamic> j) => Location(
        j['id'] as int,
        j['code'] as String,
        j['zone'] as String? ?? '',
        j['capacity'] as int? ?? 0,
        used: j['used'] as int? ?? 0,
        itemCount: j['itemCount'] as int? ?? 0,
      );

  int get free => capacity - used;

  double get fill => capacity == 0 ? 0 : used / capacity;

  Location copyWith({int? used, int? itemCount}) => Location(
      id, code, zone, capacity,
      used: used ?? this.used, itemCount: itemCount ?? this.itemCount);
}
