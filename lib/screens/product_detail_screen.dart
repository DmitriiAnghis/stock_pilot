import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/category_avatar.dart';
import '../widgets/info_row.dart';
import '../widgets/movement_tile.dart';
import '../widgets/stat_tile.dart';

/// Экран 3. Карточка товара: остаток, текущая ячейка, история движений.
class ProductDetailScreen extends StatelessWidget {
  final int id;

  const ProductDetailScreen({super.key, required this.id});

  // Деструктивное действие → диалог подтверждения + SnackBar.
  Future<void> _delete(BuildContext context, Product product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text('«${product.name}» будет удалён из каталога.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Удалить')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Товар ${product.sku} удалён')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final product = productById(id); // экран сам ищет объект по id
    final location = locationById(product.locationId);
    final movements = movementsForProduct(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.sku),
        actions: [
          IconButton(
            onPressed: () => _delete(context, product),
            tooltip: 'Удалить',
            icon: const Icon(Icons.delete_outline),
          ),

        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CategoryAvatar(category: product.category, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: text.titleLarge),
                    const SizedBox(height: 6),
                    Chip(
                      label: Text(product.category),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              StatTile(value: '${product.quantity}', label: 'Остаток, ${product.unit}'),
              const SizedBox(width: 12),
              StatTile(value: location.code, label: 'Текущая ячейка'),
              const SizedBox(width: 12),
              StatTile(value: '${movements.length}', label: 'Операций'),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  InfoRow(icon: Icons.qr_code, label: 'SKU', value: product.sku),
                  InfoRow(icon: Icons.straighten, label: 'Единица', value: product.unit),
                  InfoRow(icon: Icons.place_outlined, label: 'Зона', value: location.zone),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context
                      .push('/operation?type=transfer&productId=${product.id}'),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Переместить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context
                      .push('/operation?type=shipment&productId=${product.id}'),

                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Отгрузить'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('История движений',
              style: text.titleMedium?.copyWith(color: scheme.primary)),
          const SizedBox(height: 8),
          if (movements.isEmpty)
            Text('Движений пока не было', style: text.bodyMedium),
          for (final m in movements)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MovementTile(movement: m),
            ),
        ],
      ),
    );
  }
}
