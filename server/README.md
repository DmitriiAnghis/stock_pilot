# StockPilot API (L5)

Backend для лабораторной работы №5. Язык — **Dart** (shelf + shelf_router),
база — **SQLite** (файл `app.db` создаётся сам при первом запуске),
аутентификация — **JWT** (HS256, срок 7 дней).

## Запуск

```
cd server
dart pub get
dart run bin/server.dart        # → http://localhost:8080
```

Переменные окружения: `PORT` (по умолчанию 8080), `JWT_SECRET`
(по умолчанию `dev-secret-change-me`), `DB_PATH` (по умолчанию `app.db`).
Изменили схему таблиц — удалите `app.db`, он создастся заново со стартовыми данными.

Для эмулятора Android сервер доступен по адресу `http://10.0.2.2:8080`.

## Контракт

Ошибки всегда приходят в одном конверте: `{"error":{"code":"...","message":"..."}}`
(коды: `VALIDATION_ERROR` 400, `UNAUTHORIZED` 401, `NOT_FOUND` 404, `EMAIL_TAKEN` 409).
Списки — пагинированный конверт `{"items":[...],"page":1,"limit":20,"total":25}`,
параметры `?page=&limit=&search=`.

| Метод | Путь | Описание |
|---|---|---|
| GET | /health | `{"status":"ok"}` |
| POST | /auth/register | `{email,password,name}` → 201 `{token,user}` |
| POST | /auth/login | `{email,password}` → 200 `{token,user}` |
| GET | /auth/me | текущий пользователь |
| GET, POST | /products | список (`?search=&category=&locationId=`), создание |
| GET, PUT, DELETE | /products/{id} | товар |
| PUT | /products/{id}/location | `{locationId}` — разместить в ячейку |
| GET, POST | /locations | ячейки (с `used` и `itemCount`), создание |
| GET, PUT, DELETE | /locations/{id} | ячейка |
| GET, POST | /stock-movements | журнал (`?type=&productId=`), провести операцию |
| GET, DELETE | /stock-movements/{id} | операция |

Все маршруты, кроме `/health` и `/auth/register|login`, требуют
заголовок `Authorization: Bearer <token>`.

Проверка через curl — скрипт `tool/smoke.sh` (сервер должен быть запущен).
