import 'package:go_router/go_router.dart';
import 'screens/catalog_screen.dart';
import 'screens/history_screen.dart';
import 'screens/location_detail_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/login_screen.dart';
import 'screens/operation_form_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/profile_screen.dart';

/// Карта маршрутов: каждый экран ТЗ получает свой адрес.
final router = GoRouter(
  initialLocation: '/login', // приложение стартует в аутентификации
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const CatalogScreen(),
    ),
    GoRoute(
      path: '/products/:id', // /products/3
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ProductDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/locations',
      builder: (context, state) => const LocationsScreen(),
    ),
    GoRoute(
      path: '/locations/:id', // /locations/4
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return LocationDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    // Форма операции: параметры — в query (?productId=3&type=transfer),
    // а не в extra — адрес остаётся самодостаточным.
    GoRoute(
      path: '/operation',
      builder: (context, state) => OperationFormScreen(
        productId: int.tryParse(state.uri.queryParameters['productId'] ?? ''),
        toLocationId:
            int.tryParse(state.uri.queryParameters['toLocationId'] ?? ''),
        type: state.uri.queryParameters['type'],
      ),
    ),
  ],
);
