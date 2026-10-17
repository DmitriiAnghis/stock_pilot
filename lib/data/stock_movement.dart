enum MovementType { receipt, shipment, transfer }

/// Складская операция (движение товара).
class StockMovement {
  final int id;
  final int productId;
  final MovementType type;
  final int quantity;
  final int? fromLocationId;
  final int? toLocationId;
  final int userId;
  final String note;
  final DateTime createdAt;

  const StockMovement(this.id, this.productId, this.type, this.quantity,
      this.fromLocationId, this.toLocationId, this.userId, this.note,
      this.createdAt);

  factory StockMovement.fromJson(Map<String, dynamic> j) => StockMovement(
        j['id'] as int,
        j['productId'] as int,
        MovementType.values.byName(j['type'] as String),
        j['quantity'] as int,
        j['fromLocationId'] as int?,
        j['toLocationId'] as int?,
        j['userId'] as int? ?? 0,
        j['note'] as String? ?? '',
        DateTime.parse(j['createdAt'] as String).toLocal(),
      );

  /// Без id, userId и даты — их проставляет сервер.
  Map<String, dynamic> toJson() => {
        'productId': productId,
        'type': type.name,
        'quantity': quantity,
        'fromLocationId': fromLocationId,
        'toLocationId': toLocationId,
        'note': note,
      };

  StockMovement copyWith
({int? id}) => StockMovement(id ?? this.id, productId,
      type, quantity, fromLocationId, toLocationId, userId, note, createdAt);
}
