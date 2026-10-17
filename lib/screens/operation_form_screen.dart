import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/product.dart';
import '../data/stock_movement.dart';
import '../models/locations_model.dart';
import '../models/movements_model.dart';
import '../models/products_model.dart';
import '../widgets/movement_tile.dart';

/// Экран 4. Форма складской операции: тип, товар, количество, ячейки.
/// Валидный submit пишет операцию через модель → repository.
class OperationFormScreen extends StatefulWidget {
  final int? productId;
  final int? toLocationId;
  final String? type;

  const OperationFormScreen(
      {super.key, this.productId, this.toLocationId, this.type});

  @override
  State<OperationFormScreen> createState() => _OperationFormScreenState();
}

class _OperationFormScreenState extends State<OperationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late MovementType _type;
  int? _productId;
  int? _fromId;
  int? _toId;
  bool _busy = false; // гасит кнопку на время запроса

  @override
  void initState() {
    super.initState();
    // начальные значения приходят из адреса (?type=…&productId=…)
    _type = MovementType.values.firstWhere((t) => t.name == widget.type,
        orElse: () => MovementType.receipt);
    _productId = widget.productId;
    _toId = widget.toLocationId;
    if (_productId != null && _type != MovementType.receipt) {
      _fromId = context.read<ProductsModel>().byId(_productId!)?.locationId;
    }
  }

  Product? get _product =>
      _productId == null ? null : context.read<ProductsModel>().byId(_productId!);

  @override
  void dispose() {
    _qtyCtrl.dispose(); // кто создаёт, тот освобождает
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _needsFrom => _type != MovementType.receipt;
  bool get _needsTo => _type != MovementType.shipment;

  String? _validateQty(String? value) {
    final qty = int.tryParse(value ?? '');
    if (qty == null) return 'Введите количество';
    if (qty <= 0) return 'Количество должно быть больше нуля';
    if (qty > 100000) return 'Слишком большое количество';
    final product = _product;
    if (_needsFrom && product != null && qty > product.quantity) {
      return 'На остатке только ${product.quantity}';
    }
    return null; // null = ВАЛИДНО
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return; // валидация L3, нетронута

    final draft = StockMovement(
      0, // временный id — настоящий даст хранилище (на L5: сервер)
      _productId!,
      _type,
      int.parse(_qtyCtrl.text),
      _needsFrom ? _fromId : null,
      _needsTo ? _toId : null,
      0, // пользователя определяет хранилище
      _noteCtrl.text.trim(),
      DateTime.now(),
    );

    setState(() => _busy = true);
    final error = await context.read<MovementsModel>().add(draft);
    if (!mounted) return; // экран может умереть, пока запрос летит
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error))); // данные остаются
      return;
    }
    // операция изменила остаток и ячейки — тихо обновляем их модели
    context.read<ProductsModel>().refresh();
    context.read<LocationsModel>().refresh();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${movementLabel(_type)} проведена')));
    context.pop(); // история позади УЖЕ выросла
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final products = context.watch<ProductsModel>().products;
    final locations = context.watch<LocationsModel>().locations;
    final unit = _product?.unit;
    final locationItems = [
      for (final l in locations)
        DropdownMenuItem(value: l.id, child: Text('${l.code} · ${l.zone}')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Новая операция')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Тип операции', style: text.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in MovementType.values)
                  ChoiceChip(
                    avatar: Icon(movementIcon(t), size: 18),
                    label: Text(movementLabel(t)),
                    selected: t == _type,
                    onSelected: (_) => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              // значение из адреса берём, только если такой товар уже загружен
              initialValue:
                  products.any((p) => p.id == _productId) ? _productId : null,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Товар',
                prefixIcon: Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(),
              ),
              items: [
                for (final p in products)
                  DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.sku} · ${p.name}',
                        overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _productId = v),
              validator: (v) => v == null ? 'Выберите товар' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Количество',
                prefixIcon: const Icon(Icons.numbers),
                suffixText: unit,
                border: const OutlineInputBorder(),
              ),
              validator: _validateQty,
            ),
            if (_needsFrom) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                key: const ValueKey('from'),
                initialValue:
                    locations.any((l) => l.id == _fromId) ? _fromId : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Из ячейки',
                  prefixIcon: Icon(Icons.logout),
                  border: OutlineInputBorder(),
                ),
                items: locationItems,
                onChanged: (v) => setState(() => _fromId = v),
                validator: (v) => v == null ? 'Укажите ячейку-источник' : null,
              ),
            ],
            if (_needsTo) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                key: const ValueKey('to'),
                initialValue:
                    locations.any((l) => l.id == _toId) ? _toId : null,

                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'В ячейку',
                  prefixIcon: Icon(Icons.login),
                  border: OutlineInputBorder(),
                ),
                items: locationItems,
                onChanged: (v) => setState(() => _toId = v),
                validator: (v) {
                  if (v == null) return 'Укажите ячейку назначения';
                  if (_type == MovementType.transfer && v == _fromId) {
                    return 'Ячейки должны различаться';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 3,
              maxLength: 200,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Примечание',
                hintText: 'Например: накладная №4521',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style:
                  FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: _busy ? null : _save,

              icon: const Icon(Icons.check),
              label: const Text('Провести операцию'),
            ),
          ],
        ),
      ),
    );
  }
}
