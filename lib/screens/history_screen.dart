import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/stock_movement.dart';
import '../models/movements_model.dart';
import '../utils/format.dart';
import '../widgets/error_view.dart';
import '../widgets/movement_tile.dart';

/// Экран 7. История операций: список движений + фильтр по типу и дате.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // фильтры — эфемерное состояние → setState
  MovementType? _type;
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: _range,
    );
    setState(() => _range = picked); // null = «за всё время»
  }

  List<StockMovement> _filter(List<StockMovement> all) => all.where((m) {
        if (_type != null && m.type != _type) return false;
        if (_range != null) {
          final day = DateUtils.dateOnly(m.createdAt);
          if (day.isBefore(_range!.start) || day.isAfter(_range!.end)) {
            return false;
          }
        }
        return true;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MovementsModel>();

    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!,
        onRetry: () => context.read<MovementsModel>().load(),
      );
    } else {
      final items = _filter(model.movements);
      body = items.isEmpty
          ? const Center(child: Text('Операций не найдено'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) => MovementTile(
                  key: ValueKey(items[index].id), movement: items[index]),
            );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('История операций'),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Экспорт CSV будет доступен позже'))),
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
                FilterChip(
                    label: const Text('Все'),
                    selected: _type == null,
                    onSelected: (_) => setState(() => _type = null)),
                const SizedBox(width: 8),
                for (final t in MovementType.values) ...[
                  FilterChip(
                    avatar: Icon(movementIcon(t), size: 18),
                    label: Text(movementLabel(t)),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
                  const SizedBox(width: 8),
                ],
                ActionChip(
                  avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(_range == null
                      ? 'За всё время'
                      : '${formatDay(_range!.start)} – ${formatDay(_range!.end)}'),
                  onPressed: _pickRange,
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
