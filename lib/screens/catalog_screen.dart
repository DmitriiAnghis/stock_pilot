import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/product.dart';
import '../models/locations_model.dart';
import '../models/products_model.dart';
import '../widgets/error_view.dart';
import '../widgets/product_card.dart';

/// Экран 2. Каталог товаров: поиск по названию/SKU + фильтр по категории/ячейке.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // фильтры — эфемерное состояние экрана → setState
  // (поиск по названию/SKU идёт на сервере — через модель)
  String _category = 'Все';
  int? _locationId;

  List<Product> _filter(List<Product> all) => all.where((p) {
        if (_category != 'Все' && p.category != _category) return false;
        if (_locationId != null && p.locationId != _locationId) return false;
        return true;
      }).toList();

  Future<void> _pickLocation() async {
    final locations = context.read<LocationsModel>().locations;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetCtx) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Все ячейки'),
            onTap: () => Navigator.pop(sheetCtx, -1),
          ),
          for (final l in locations)
            ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: Text(l.code),
              subtitle: Text(l.zone),
              onTap: () => Navigator.pop(sheetCtx, l.id),
            ),
        ],
      ),
    );
    if (picked != null) {
      setState(() => _locationId = picked == -1 ? null : picked);
    }
  }

  // Удаление свайпом: диалог подтверждения → мутация через модель.
  Future<bool> _confirmDelete(Product product) async {
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
    if (ok != true || !mounted) return false;
    final error = await context.read<ProductsModel>().remove(product.id);
    if (!mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error ?? 'Товар ${product.sku} удалён')));
    return error == null;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProductsModel>(); // watch в build
    final locationCode = _locationId == null
        ? 'все'
        : context.watch<LocationsModel>().codeOf(_locationId);
    final categories = [
      'Все',
      ...{for (final p in model.products) p.category},
    ];

    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator()); // 1) грузится
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!, // 2) упало
        onRetry: () => context.read<ProductsModel>().load(), // read: действие
      );
    } else {
      final items = _filter(model.products); // 3) данные
      body = Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final c in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c),
                      selected: c == _category,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.grid_view_rounded, size: 18),
                  label: Text('Ячейка: $locationCode'),
                  onPressed: _pickLocation,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Показано товаров: ${items.length}',

                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              // хвост списка просит следующую страницу
              itemCount: items.length + (model.hasMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  context.read<ProductsModel>().loadMore();
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                final product = items[index];
                return Dismissible(
                  key: ValueKey(product.id), // идентичность из данных
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(product),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Icon(Icons.delete_outline),
                  ),
                  child: ProductCard(
                    product: product,
                    // push: «зайду и вернусь», id — в адресе
                    onTap: () => context.push('/products/${product.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог товаров'),
        actions: [
          // один живой угол — Consumer: badge товаров с низким остатком
          Consumer<ProductsModel>(
            builder: (context, products, child) => IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Низкий остаток (< 10): ${products.lowStockCount} поз.'))),
              tooltip: 'Уведомления',
              icon: Badge(
                isLabelVisible: products.lowStockCount > 0,
                label: Text('${products.lowStockCount}'),
                child: child!,
              ),
            ),
            child: const Icon(Icons.notifications_none),
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
              // поиск на сервере: ?search=
              onSubmitted: (q) =>
                  context.read<ProductsModel>().load(search: q.trim()),
              elevation: const WidgetStatePropertyAll(0),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
