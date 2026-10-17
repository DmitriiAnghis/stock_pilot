import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/product_card.dart';


/// Экран 2. Каталог товаров: поиск по названию/SKU + фильтр по категории/ячейке.
/// Поиск и фильтры пока только визуальные — заработают на L4.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог товаров'),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Уведомления',
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/operation'),
        icon: const Icon(Icons.add),
        label: const Text('Операция'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              hintText: 'Поиск по названию или SKU',
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ],
              elevation: const WidgetStatePropertyAll(0),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final c in mockCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c),
                      selected: c == 'Все',
                      onSelected: (_) {},
                    ),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.grid_view_rounded, size: 18),
                  label: const Text('Ячейка: все'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Найдено товаров: ${mockProducts.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: mockProducts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = mockProducts[index];
                return ProductCard(
                  product: product,
                  // push: «зайду и вернусь», id — в адресе
                  onTap: () => context.push('/products/${product.id}'),

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
