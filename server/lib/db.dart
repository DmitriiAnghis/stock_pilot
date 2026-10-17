import 'package:sqlite3/sqlite3.dart';

/// Открывает app.db и применяет схему (CREATE TABLE IF NOT EXISTS).
/// Изменили колонки — удалите app.db: существующая таблица не изменится.
Database openDb(String path) {
  final db = sqlite3.open(path);
  db.execute('PRAGMA foreign_keys = ON;');
  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      password_hash TEXT NOT NULL,
      salt TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
    CREATE TABLE IF NOT EXISTS locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT NOT NULL UNIQUE,
      zone TEXT NOT NULL,
      capacity INTEGER NOT NULL
    );
    CREATE TABLE IF NOT EXISTS products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sku TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      unit TEXT NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 0,
      location_id INTEGER REFERENCES locations(id),
      image_url TEXT NOT NULL DEFAULT ''
    );
    CREATE TABLE IF NOT EXISTS stock_movements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      type TEXT NOT NULL CHECK (type IN ('receipt','shipment','transfer')),
      quantity INTEGER NOT NULL,
      from_location_id INTEGER REFERENCES locations(id),
      to_location_id INTEGER REFERENCES locations(id),
      user_id INTEGER NOT NULL REFERENCES users(id),
      note TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL
    );
  ''');
  _seed(db);
  return db;
}

/// Стартовые данные склада — только в пустую базу.
void _seed(Database db) {
  final count = db.select('SELECT COUNT(*) AS c FROM locations').first['c'];
  if (count != 0) return;
  const locations = [
    ['A-01-01', 'Зона A · Стеллажи', 400],
    ['A-01-02', 'Зона A · Стеллажи', 800],
    ['A-02-01', 'Зона A · Стеллажи', 300],
    ['B-01-01', 'Зона B · Паллетное хранение', 1200],
    ['B-02-03', 'Зона B · Паллетное хранение', 1200],
    ['C-01-01', 'Зона C · Мелкие детали', 150],
    ['C-03-02', 'Зона C · Мелкие детали', 150],
    ['R-00-01', 'Зона приёмки', 800],
  ];
  for (final l in locations) {
    db.execute(
        'INSERT INTO locations (code, zone, capacity) VALUES (?, ?, ?)', l);
  }
  const products = [
    ['SKU-10234', 'Коробка картонная 60×40×40 см, гофрокартон Т-24', 'Упаковка', 'шт', 340, 4],
    ['SKU-10871', 'Стрейч-плёнка 500 мм × 300 м, 20 мкм', 'Упаковка', 'рул', 86, 1],
    ['SKU-20415', 'Перчатки рабочие х/б с ПВХ, размер 10', 'Спецодежда', 'пар', 120, 6],
    ['SKU-20990', 'Жилет сигнальный оранжевый, 2 класс', 'Спецодежда', 'шт', 45, 7],
    ['SKU-31002', 'Сканер штрихкодов Zebra DS2208', 'Оборудование', 'шт', 12, 3],
    ['SKU-31550', 'Этикет-принтер Xprinter XP-365B', 'Оборудование', 'шт', 4, 3],
    ['SKU-42017', 'Скотч упаковочный прозрачный 48 мм × 66 м', 'Упаковка', 'шт', 610, 2],
    ['SKU-55120', 'Паллета деревянная EUR 1200×800', 'Тара', 'шт', 58, 5],
    ['SKU-55300', 'Ящик пластиковый 600×400×300, серый', 'Тара', 'шт', 7, 8],
  ];
  for (final p in products) {
    db.execute(
        'INSERT INTO products (sku, name, category, unit, quantity, location_id) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        p);
  }
  // ещё 16 позиций, чтобы список был длиннее одной страницы (пагинация)
  for (var i = 1; i <= 16; i++) {
    db.execute(
        'INSERT INTO products (sku, name, category, unit, quantity, location_id) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        ['SKU-9${i.toString().padLeft(4, '0')}', 'Стяжка кабельная 200 мм, упаковка №$i',
         'Расходники', 'уп', 20 + i * 5, 6 + i % 2]);
  }
}
