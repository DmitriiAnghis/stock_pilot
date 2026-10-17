import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/locations_model.dart';
import '../widgets/error_view.dart';
import '../widgets/location_card.dart';

/// Экран 5. Складские ячейки: список с загруженностью + поиск по коду ячейки.
class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  String _query = ''; // эфемерное состояние → setState

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LocationsModel>();

    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!,
        onRetry: () => context.read<LocationsModel>().load(),
      );
    } else {
      final q = _query.trim().toUpperCase();
      final items =
          model.locations.where((l) => l.code.contains(q)).toList();
      body = items.isEmpty
          ? const Center(child: Text('Ячейки не найдены'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final location = items[index];
                return LocationCard(
                  location: location,
                  onTap: () => context.push('/locations/${location.id}'),
                );
              },
            );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Складские ячейки')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              hintText: 'Код ячейки, например A-01-02',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
              elevation: const WidgetStatePropertyAll(0),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
