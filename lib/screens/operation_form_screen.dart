import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/movement_tile.dart';

/// Экран 4. Форма складской операции: тип, товар, количество, ячейки.
/// L3: форма валидирует локально; данные пока никуда не сохраняются.
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

  @override
  void initState() {
    super.initState();
    // начальные значения приходят из адреса (?type=…&productId=…)
    _type = MovementType.values.firstWhere((t) => t.name == widget.type,
        orElse: () => MovementType.receipt);
    _productId = widget.productId;
    _toId = widget.toLocationId;
    if (_productId != null && _type != MovementType.receipt) {
      _fromId = productById(_productId!).locationId;
    }
  }

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
    if (_needsFrom && _productId != null) {
      final stock = productById(_productId!).quantity;
      if (qty > stock) return 'На остатке только $stock';
    }
    return null; // null = ВАЛИДНО
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return; // ошибки уже на экране
    final product = productById(_productId!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${movementLabel(_type)} проведена: ${product.sku}, ${_qtyCtrl.text} ${product.unit}')));
    context.pop(); // открыто push-ем → закрывается pop-ом
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final locationItems = [
      for (final l in mockLocations)
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
              initialValue: _productId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Товар',
                prefixIcon: Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(),
              ),
              items: [
                for (final p in mockProducts)
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
                suffixText: _productId == null
                    ? null
                    : productById(_productId!).unit,
                border: const OutlineInputBorder(),
              ),
              validator: _validateQty,
            ),
            if (_needsFrom) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                key: const ValueKey('from'),
                initialValue: _fromId,
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
                initialValue: _toId,
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
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Провести операцию'),
            ),
          ],
        ),
      ),
    );
  }
}
