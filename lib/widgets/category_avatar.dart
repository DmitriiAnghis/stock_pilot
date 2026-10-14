import 'package:flutter/material.dart';

/// Квадратная иконка категории товара (заглушка вместо фото товара).
/// Используется: каталог, карточка товара, карточка ячейки.
class CategoryAvatar extends StatelessWidget {
  final String category;
  final double size;

  const CategoryAvatar({super.key, required this.category, this.size = 48});

  IconData get _icon => switch (category) {
        'Упаковка' => Icons.inventory_2_outlined,
        'Спецодежда' => Icons.checkroom_outlined,
        'Оборудование' => Icons.qr_code_scanner,
        'Тара' => Icons.all_inbox_outlined,
        _ => Icons.category_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(_icon, size: size * 0.5, color: scheme.onPrimaryContainer),
    );
  }
}
