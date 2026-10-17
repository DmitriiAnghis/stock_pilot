import 'package:go_router/go_router.dart';
import 'screens/catalog_screen.dart';
import 'screens/history_screen.dart';
import 'screens/location_detail_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/login_screen.dart';
import 'screens/operation_form_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/app_shell.dart';

/// Карта маршрутов: login и форма операции — снаружи, разделы — во вкладках.
final router = GoRouter(
  initialLocation: '/login', // приложение стартует в аутентификации
  routes: [
    GoRoute(
      path: '/login', // ВНЕ shell-а: login без вкладок
      builder: (context, state) => const LoginScreen(),
    ),
    // Форма операции открывается поверх вкладок (push) и закрывается pop-ом.
    // Параметры — в query (?productId=3&type=transfer), а не в extra.
    GoRoute(
      path: '/operation',
      builder: (context, state) => OperationFormScreen(
        productId: int.tryParse(state.uri.queryParameters['productId'] ?? ''),
        toLocationId:
            int.tryParse(state.uri.queryParameters['toLocationId'] ?? ''),
        type: state.uri.queryParameters['type'],
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/products',
            builder: (context, state) => const CatalogScreen(),
            routes: [
              GoRoute(
                path: ':id', // полный адрес: /products/3
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return ProductDetailScreen(id: id);
                },
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/locations',
            builder: (context, state) => const LocationsScreen(),
            routes: [
              GoRoute(
                path: ':id', // полный адрес: /locations/4
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return LocationDetailScreen(id: id);
                },
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ]),
      ],
    ),
  ],
);
