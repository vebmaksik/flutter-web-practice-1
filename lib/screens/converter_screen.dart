import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../logic/currency.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _from = 'RUB';
  String _to = 'USD';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _restorePair();
  }

  Future<void> _restorePair() async {
    final (from, to) = await loadLastPair();
    if (!mounted) return;
    setState(() {
      _from = from;
      _to = to;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите сумму';
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Это не число';
    if (parsed < 0) return 'Сумма не может быть отрицательной';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await saveLastPair(_from, _to);
    if (!mounted) return;
    final amount = _amountController.text.replaceAll(',', '.');
    context.go('/converter/result?amount=$amount&from=$_from&to=$_to');
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Конвертер валют')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Сумма'),
                    keyboardType: TextInputType.number,
                    validator: _amountValidator,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _from,
                    decoration: const InputDecoration(labelText: 'Из валюты'),
                    items: currencyRates.keys
                        .map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: Text('$code — ${currencyNames[code]}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _from = v ?? 'RUB'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _to,
                    decoration: const InputDecoration(labelText: 'В валюту'),
                    items: currencyRates.keys
                        .map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: Text('$code — ${currencyNames[code]}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _to = v ?? 'USD'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Конвертировать'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('На главную'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
