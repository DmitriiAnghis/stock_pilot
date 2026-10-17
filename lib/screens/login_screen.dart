import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Экран 1. Вход / регистрация.
/// L3: локальная валидация; любые корректные e-mail и пароль пропускают внутрь.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true; // эфемерное состояние — setState

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.go('/products'); // go, НЕ push: login уходит из стека
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
                onPressed: _submit,
                child: const Text('Войти'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: const Text('Нет аккаунта? Зарегистрируйтесь'),
              ),
              const SizedBox(height: 24),
              Text('версия 0.3 · L3',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: scheme.outline)),
            ],
          ),
        ),
      ),
    );
  }
}
