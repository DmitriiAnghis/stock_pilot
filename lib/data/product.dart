/// Товар — доменная модель (переживёт mock и перейдёт на L5).
class Product {
  final int id;
  final String sku;
  final String name;
  final String category;
  final String unit;
  final int quantity;
  final int locationId;
  final String imageUrl;

  const Product(this.id, this.sku, this.name, this.category, this.unit,
      this.quantity, this.locationId, this.imageUrl);

  /// «Тот же товар, другие поля» — для mock-хранилища.
  Product copyWith({int? id, int? quantity, int? locationId}) => Product(
      id ?? this.id,
      sku,
      name,
      category,
      unit,
      quantity ?? this.quantity,
      locationId ?? this.locationId,
      imageUrl);
}
