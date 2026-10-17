import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/info_row.dart';
import '../widgets/stat_tile.dart';
import 'package:go_router/go_router.dart';

/// Экран 8. Профиль пользователя.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: scheme.primaryContainer,
              child: Text('ДА',
                  style: text.headlineMedium
                      ?.copyWith(color: scheme.onPrimaryContainer)),
            ),
          ),
          const SizedBox(height: 12),
          Text(mockUserName, textAlign: TextAlign.center, style: text.titleLarge),
          Text(mockUserRole,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          Row(
            children: [
              StatTile(value: '${mockMovements.length}', label: 'Операций'),
              const SizedBox(width: 12),
              StatTile(value: '${mockProducts.length}', label: 'Товаров'),
              const SizedBox(width: 12),
              StatTile(value: '${mockLocations.length}', label: 'Ячеек'),
            ],
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  InfoRow(icon: Icons.mail_outline, label: 'E-mail', value: mockUserEmail),
                  InfoRow(icon: Icons.badge_outlined, label: 'Табельный №', value: '0472'),
                  InfoRow(icon: Icons.schedule, label: 'Смена', value: '08:00 – 20:00'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Уведомления о низком остатке'),
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Экспорт истории в CSV'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: scheme.error,
            ),
            onPressed: () => context.go('/login'),

            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
