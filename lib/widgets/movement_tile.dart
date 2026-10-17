import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/stock_movement.dart';
import '../models/locations_model.dart';
import '../models/products_model.dart';
import '../utils/format.dart';

/// Название типа операции.
String movementLabel(MovementType type) => switch (type) {
      MovementType.receipt => 'Приёмка',
      MovementType.shipment => 'Отгрузка',
      MovementType.transfer => 'Перемещение',
    };

/// Иконка типа операции.
IconData movementIcon(MovementType type) => switch (type) {
      MovementType.receipt => Icons.south_west,
      MovementType.shipment => Icons.north_east,
      MovementType.transfer => Icons.swap_horiz,
    };

/// Строка истории движения товара.
/// Используется: история операций, карточка товара.
class MovementTile extends StatelessWidget {
  final StockMovement movement;

  const MovementTile({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final product = context.watch<ProductsModel>().byId(movement.productId);
    final locations = context.watch<LocationsModel>();
    final name = product?.name ?? 'Товар #${movement.productId}';
    final unit = product?.unit ?? '';

    // цвета берём только из темы
    final (bg, fg) = switch (movement.type) {
      MovementType.receipt => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      MovementType.shipment => (scheme.errorContainer, scheme.onErrorContainer),
      MovementType.transfer => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };

    final sign = switch (movement.type) {
      MovementType.receipt => '+',
      MovementType.shipment => '−',
      MovementType.transfer => '',
    };

    final from = locations.codeOf(movement.fromLocationId);
    final to = locations.codeOf(movement.toLocationId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: bg,
              child: Icon(movementIcon(movement.type), color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${movementLabel(movement.type)} · $from → $to',
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  Text(
                    formatDate(movement.createdAt),
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sign${movement.quantity} $unit',

              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
