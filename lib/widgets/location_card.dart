import 'package:flutter/material.dart';
import '../data/location.dart';

/// Карточка складской ячейки с полоской загруженности.
/// Используется: список ячеек.
class LocationCard extends StatelessWidget {
  final Location location;
  final VoidCallback? onTap;

  const LocationCard({super.key, required this.location, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final used = location.used;
    final percent = location.fill.clamp(0.0, 1.0);
    final count = location.itemCount;


    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.grid_view_rounded, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(location.code, style: text.titleMedium),
                  const Spacer(),
                  Text(
                    '${(percent * 100).round()}%',
                    style: text.titleMedium?.copyWith(
                      color: percent > 0.75 ? scheme.error : scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${location.zone} · позиций: $count',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  color: percent > 0.75 ? scheme.error : scheme.primary,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Занято $used из ${location.capacity} ед.',
                style: text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
