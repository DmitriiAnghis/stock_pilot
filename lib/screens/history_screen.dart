import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/movement_tile.dart';

/// Экран 7. История операций: список движений + фильтр по типу и дате.
/// Фильтры пока только визуальные — заработают на L4.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История операций'),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Экспорт в CSV',
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                FilterChip(label: const Text('Все'), selected: true, onSelected: (_) {}),
                const SizedBox(width: 8),
                for (final t in MovementType.values) ...[
                  FilterChip(
                    avatar: Icon(movementIcon(t), size: 18),
                    label: Text(movementLabel(t)),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  const SizedBox(width: 8),
                ],
                ActionChip(
                  avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: const Text('10.10 – 14.10.2026'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: mockMovements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  MovementTile(movement: mockMovements[index]),
            ),
          ),
        ],
      ),
    );
  }
}
