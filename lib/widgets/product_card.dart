import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'category_avatar.dart';

/// Карточка товара в списке.
/// Используется: каталог товаров, карточка ячейки.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final location = locationById(product.locationId);
    final isLow = product.quantity < 10;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CategoryAvatar(category: product.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.sku} · ячейка ${location.code}',
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.quantity}',
                    style: text.titleLarge?.copyWith(
                      color: isLow ? scheme.error : scheme.primary,
                    ),
                  ),
                  Text(product.unit, style: text.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
