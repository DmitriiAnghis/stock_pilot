import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/location_card.dart';


/// Экран 5. Складские ячейки: список с загруженностью + поиск по коду ячейки.
class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Складские ячейки')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              hintText: 'Код ячейки, например A-01-02',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: mockLocations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final location = mockLocations[index];
                return LocationCard(
                  location: location,
                  onTap: () => context.push('/locations/${location.id}'),

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
