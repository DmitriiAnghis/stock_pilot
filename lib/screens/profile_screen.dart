import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/auth_api.dart';
import '../data/mock_repositories.dart';
import '../models/locations_model.dart';
import '../models/movements_model.dart';
import '../models/products_model.dart';
import '../models/profile_model.dart';
import '../widgets/error_view.dart';
import '../widgets/info_row.dart';
import '../widgets/stat_tile.dart';

/// Экран 8. Профиль пользователя.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _lowStockAlerts = true; // эфемерное состояние → setState
  bool _simulateError = false; // леса демонстрации аварии — умрут на L5

  // Блокирующее решение → AlertDialog с результатом.
  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Для продолжения работы нужно будет войти снова.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Нет')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Да, выйти')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<AuthApi>().logout(); // token стирается из prefs
    if (mounted) context.go('/login'); // go: вкладки уходят из стека

  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final model = context.watch<ProfileModel>();
    final user = model.user;

    if (model.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (model.error != null || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Профиль')),
        body: ErrorView(
          message: model.error ?? 'Нет данных пользователя',
          onRetry: () => context.read<ProfileModel>().load(),
        ),
      );
    }

    final movements = context.watch<MovementsModel>().movements.length;
    final products = context.watch<ProductsModel>().products.length;
    final locations = context.watch<LocationsModel>().locations.length;

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
              child: Text(user.initials,
                  style: text.headlineMedium
                      ?.copyWith(color: scheme.onPrimaryContainer)),
            ),
          ),
          const SizedBox(height: 12),
          Text(user.name, textAlign: TextAlign.center, style: text.titleLarge),
          Text('Кладовщик · Склад «Центральный»',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          Row(
            children: [
              StatTile(value: '$movements', label: 'Операций'),
              const SizedBox(width: 12),
              StatTile(value: '$products', label: 'Товаров'),
              const SizedBox(width: 12),
              StatTile(value: '$locations', label: 'Ячеек'),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  InfoRow(
                      icon: Icons.mail_outline,
                      label: 'E-mail',
                      value: user.email),
                  InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'ID пользователя',
                      value: '${user.id}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _lowStockAlerts,
                  onChanged: (v) => setState(() => _lowStockAlerts = v),
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Уведомления о низком остатке'),
                ),
                // Единственное место UI, которое знает о mock-е.
                SwitchListTile(
                  value: _simulateError,
                  onChanged: (v) {
                    setState(() => _simulateError = v);
                    context.read<MockBackend>().simulateError = v;
                  },
                  secondary: const Icon(Icons.wifi_off),
                  title: const Text('Симулировать сбой сети'),
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Экспорт истории в CSV'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Экспорт CSV будет доступен позже'))),
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
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
