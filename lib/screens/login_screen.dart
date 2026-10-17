import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/auth_api.dart';
import '../data/result.dart';
import '../models/locations_model.dart';
import '../models/movements_model.dart';
import '../models/products_model.dart';
import '../models/profile_model.dart';

/// Экран 1. Вход / регистрация.
/// L5: валидный submit идёт на сервер; token сохраняется в shared_preferences.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscure = true; // эфемерное состояние — setState
  bool _isRegister = false;
  bool _busy = false; // гасит кнопку на время запроса (двойной submit)

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // валидация L3, нетронута
    final auth = context.read<AuthApi>();
    setState(() => _busy = true);
    final result = _isRegister
        ? await auth.register(
            _emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim())
        : await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return; // экран может умереть, пока запрос летит
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        // новый пользователь — данные загружаются заново, уже с token-ом
        context.read<ProductsModel>().load();
        context.read<LocationsModel>().load();
        context.read<MovementsModel>().load();
        context.read<ProfileModel>().load();
        context.go('/products'); // go, НЕ push: login уходит из стека
      case Err(:final msg):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.warehouse_outlined,
                      size: 48, color: scheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 20),
              Text('StockPilot',
                  textAlign: TextAlign.center,
                  style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700, color: scheme.primary)),
              const SizedBox(height: 6),
              Text('Складской учёт без бумаги и Excel',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 40),
              if (_isRegister) ...[
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Введите имя'
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.mail_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Введите e-mail';
                  if (!_emailRe.hasMatch(value)) return 'Некорректный e-mail';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введите пароль';
                  if (v.length < 6) return 'Минимум 6 символов';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isRegister ? 'Зарегистрироваться' : 'Войти'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _isRegister = !_isRegister),
                child: Text(_isRegister
                    ? 'Уже есть аккаунт? Войти'
                    : 'Нет аккаунта? Зарегистрируйтесь'),
              ),
              const SizedBox(height: 24),
              Text('версия 0.5 · L5',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: scheme.outline)),
            ],
          ),
        ),
      ),
    );
  }
}
