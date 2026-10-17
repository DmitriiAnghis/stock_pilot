import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/movement_tile.dart';

/// Экран 4. Форма складской операции: тип, товар, количество, ячейки.
/// Макет: без валидации и сохранения (это L3/L4).
class OperationFormScreen extends StatelessWidget {
  final int? productId;
  final int? toLocationId;
  final String? type;

  const OperationFormScreen(
      {super.key, this.productId, this.toLocationId, this.type});


  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Новая операция')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Тип операции', style: text.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in MovementType.values)
                ChoiceChip(
                  avatar: Icon(movementIcon(t), size: 18),
                  label: Text(movementLabel(t)),
                  selected: t == MovementType.receipt,
                  onSelected: (_) {},
                ),
            ],
          ),
          const SizedBox(height: 24),
          DropdownMenu<int>(
            expandedInsets: EdgeInsets.zero,
            label: const Text('Товар'),
            leadingIcon: const Icon(Icons.inventory_2_outlined),
            initialSelection: mockProducts.first.id,
            dropdownMenuEntries: [
              for (final p in mockProducts)
                DropdownMenuEntry(value: p.id, label: '${p.sku} · ${p.name}'),
            ],
          ),
          const SizedBox(height: 16),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Количество',
              prefixIcon: Icon(Icons.numbers),
              suffixText: 'шт',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownMenu<int>(
            expandedInsets: EdgeInsets.zero,
            label: const Text('Из ячейки'),
            leadingIcon: const Icon(Icons.logout),
            dropdownMenuEntries: [
              for (final l in mockLocations)
                DropdownMenuEntry(value: l.id, label: l.code),
            ],
          ),
          const SizedBox(height: 16),
          DropdownMenu<int>(
            expandedInsets: EdgeInsets.zero,
            label: const Text('В ячейку'),
            leadingIcon: const Icon(Icons.login),
            initialSelection: mockLocations[3].id,
            dropdownMenuEntries: [
              for (final l in mockLocations)
                DropdownMenuEntry(value: l.id, label: l.code),
            ],
          ),
          const SizedBox(height: 16),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Примечание',
              hintText: 'Например: накладная №4521',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: () {},
            icon: const Icon(Icons.check),
            label: const Text('Провести операцию'),
          ),
        ],
      ),
    );
  }
}
