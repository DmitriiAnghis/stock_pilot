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

  StockMovement copyWith({int? id}) => StockMovement(id ?? this.id, productId,
      type, quantity, fromLocationId, toLocationId, userId, note, createdAt);
}
