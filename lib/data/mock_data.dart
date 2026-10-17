// Seed-данные для mock-хранилища (L4). Единственный клиент этого файла —
// data/mock_repositories.dart; ни один экран и ни одна модель его не импортируют.
import 'app_user.dart';
import 'location.dart';
import 'product.dart';
import 'stock_movement.dart';

// ---------- Ячейки склада ----------
const mockLocations = [
  Location(1, 'A-01-01', 'Зона A · Стеллажи', 400),
  Location(2, 'A-01-02', 'Зона A · Стеллажи', 800),
  Location(3, 'A-02-01', 'Зона A · Стеллажи', 300),
  Location(4, 'B-01-01', 'Зона B · Паллетное хранение', 1200),
  Location(5, 'B-02-03', 'Зона B · Паллетное хранение', 1200),
  Location(6, 'C-01-01', 'Зона C · Мелкие детали', 150),
  Location(7, 'C-03-02', 'Зона C · Мелкие детали', 150),
  Location(8, 'R-00-01', 'Зона приёмки', 800),
];

// ---------- Товары ----------
const mockProducts = [
  Product(1, 'SKU-10234', 'Коробка картонная 60×40×40 см, гофрокартон Т-24',
      'Упаковка', 'шт', 340, 4, ''),
  Product(2, 'SKU-10871', 'Стрейч-плёнка 500 мм × 300 м, 20 мкм',
      'Упаковка', 'рул', 86, 1, ''),
  Product(3, 'SKU-20415', 'Перчатки рабочие х/б с ПВХ, размер 10',
      'Спецодежда', 'пар', 120, 6, ''),
  Product(4, 'SKU-20990', 'Жилет сигнальный оранжевый, 2 класс',
      'Спецодежда', 'шт', 45, 7, ''),
  Product(5, 'SKU-31002', 'Сканер штрихкодов Zebra DS2208',
      'Оборудование', 'шт', 12, 3, ''),
  Product(6, 'SKU-31550', 'Этикет-принтер Xprinter XP-365B',
      'Оборудование', 'шт', 4, 3, ''),
  Product(7, 'SKU-42017', 'Скотч упаковочный прозрачный 48 мм × 66 м',
      'Упаковка', 'шт', 610, 2, ''),
  Product(8, 'SKU-55120', 'Паллета деревянная EUR 1200×800',
      'Тара', 'шт', 58, 5, ''),
  Product(9, 'SKU-55300', 'Ящик пластиковый 600×400×300, серый',
      'Тара', 'шт', 7, 8, ''),
];

// ---------- История движений ----------
final mockMovements = [
  StockMovement(1, 1, MovementType.receipt, 200, null, 4, 1,
      'Поставка от ООО «КартонПак», накладная №4521', DateTime(2026, 10, 14, 9, 15)),
  StockMovement(2, 7, MovementType.shipment, 48, 2, null, 1,
      'Заказ клиента #A-1187', DateTime(2026, 10, 14, 8, 40)),
  StockMovement(3, 5, MovementType.transfer, 4, 8, 3, 2,
      'Перенос из зоны приёмки на стеллаж', DateTime(2026, 10, 13, 17, 5)),
  StockMovement(4, 3, MovementType.receipt, 100, null, 6, 1,
      'Поставка «СпецОдежда-Юг»', DateTime(2026, 10, 13, 11, 30)),
  StockMovement(5, 1, MovementType.shipment, 60, 4, null, 2,
      'Заказ клиента #A-1179', DateTime(2026, 10, 12, 15, 50)),
  StockMovement(6, 8, MovementType.transfer, 20, 8, 5, 1,
      'Размещение паллет после приёмки', DateTime(2026, 10, 12, 10, 20)),
  StockMovement(7, 2, MovementType.receipt, 40, null, 1, 2,
      'Поставка от «ПолиПак»', DateTime(2026, 10, 11, 14, 0)),
  StockMovement(8, 1, MovementType.transfer, 30, 8, 4, 1,
      'Перенос из зоны приёмки', DateTime(2026, 10, 10, 9, 45)),
];

// ---------- Текущий пользователь ----------
const mockUser = AppUser(1, 'Дмитрий Ангиш', 'dmitrii.anghis@stockpilot.md');
