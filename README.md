# StockPilot

Проект по дисциплине «Программирование мобильных приложений» (PAM), ТУМ.
Мобильное приложение для складского учёта на Flutter (Material 3) + собственный backend на Dart.

## Экраны
1. Вход / регистрация — `/login`
2. Каталог товаров — `/products`
3. Карточка товара — `/products/:id`
4. Форма складской операции — `/operation?type=&productId=&toLocationId=`
5. Складские ячейки — `/locations`
6. Карточка ячейки — `/locations/:id`
7. История операций — `/history`
8. Профиль пользователя — `/profile`

## Лабораторные работы
| Лаба | Что сделано | Тег / ветка |
|---|---|---|
| L2 | Статический UI всех 8 экранов, 6 переиспользуемых widget-ов | `L2` |
| L3 | go_router: карта маршрутов, `/:id`, StatefulShellRoute + NavigationBar, формы с валидацией, SnackBar и диалоги | `L3`, `l3-navigation` |
| L4 | Provider: модели ChangeNotifier, Repository на `Future<Result<T>>`, mock с задержкой и аварией, три состояния экрана | `L4`, `l4-state-repository` |
| L5 | Backend в `server/` (Dart + SQLite + JWT), вход через сервер, token в shared_preferences, Http-репозитории, поток 401, пагинация и поиск | `L5`, `l5-backend` |

## Структура `lib/`
```
lib/
  main.dart            корень композиции: выбор источника данных, Provider-ы
  router.dart          карта маршрутов go_router
  data/                сущности, Result, интерфейсы Repository, Http-реализации, AuthApi, TokenStore
  models/              ChangeNotifier-модели: товары, ячейки, операции, профиль
  screens/             8 экранов
  widgets/             переиспользуемые widget-ы (AppShell, ProductCard, ErrorView, ...)
```

## Запуск
1. Сервер (в отдельном терминале):
   ```
   cd server
   dart pub get
   dart run bin/server.dart
   ```
   Сервер слушает `http://localhost:8080`, база `server/app.db` создаётся сама со стартовыми данными.
2. Приложение:
   ```
   flutter pub get
   flutter run
   ```
   Эмулятор Android обращается к серверу по `http://10.0.2.2:8080`. Для телефона:
   `flutter run --dart-define=API_BASE=http://<IP-ноутбука>:8080`.
3. В приложении нажмите «Нет аккаунта? Зарегистрируйтесь» и создайте пользователя.

Проверка сервера через curl: `bash server/tool/smoke.sh`.
