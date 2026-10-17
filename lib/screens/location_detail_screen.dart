import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/info_row.dart';
import '../widgets/product_card.dart';
import '../widgets/stat_tile.dart';


/// Экран 6. Карточка ячейки: товары в ячейке + кнопка «разместить товар в ячейке».
class LocationDetailScreen extends StatelessWidget {
  final int id;

  const LocationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final location = locationById(id); // экран сам ищет объект по id
    final products = productsInLocation(location.id);
    final used = usedCapacity(location.id);
    final free = location.capacity - used;

    return Scaffold(
      appBar: AppBar(title: Text('Ячейка ${location.code}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/operation?type=transfer&toLocationId=${location.id}'),
        icon: const Icon(Icons.move_to_inbox_outlined),
        label: const Text('Разместить товар в ячейке'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Row(
            children: [
              StatTile(value: '${products.length}', label: 'Позиций'),
              const SizedBox(width: 12),
              StatTile(value: '$used', label: 'Занято, ед.'),
              const SizedBox(width: 12),
              StatTile(value: '$free', label: 'Свободно, ед.'),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  InfoRow(icon: Icons.qr_code, label: 'Код', value: location.code),
                  InfoRow(icon: Icons.place_outlined, label: 'Зона', value: location.zone),
                  InfoRow(
                      icon: Icons.straighten,
                      label: 'Вместимость',
                      value: '${location.capacity} ед.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Товары в ячейке',
              style: text.titleMedium?.copyWith(color: scheme.primary)),
          const SizedBox(height: 8),
          if (products.isEmpty)
            Text('Ячейка пуста', style: text.bodyMedium),
          for (final p in products)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ProductCard(
                product: p,
                onTap: () => context.push('/products/${p.id}'),

              ),
            ),
        ],
      ),
    );
  }
}
