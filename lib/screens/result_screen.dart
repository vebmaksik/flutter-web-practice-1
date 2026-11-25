import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../logic/calculator.dart';
import '../logic/currency.dart';

class ResultScreen extends StatelessWidget {
  final String title;
  final String expression;
  final Map<String, String> rawQuery;
  final String backPath;

  const ResultScreen({
    super.key,
    required this.title,
    required this.expression,
    required this.rawQuery,
    required this.backPath,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCalculator = rawQuery.containsKey('op');

    final resultText = isCalculator
        ? _calcResult(rawQuery)
        : _convertResult(rawQuery);

    final isError = resultText.startsWith('Ошибка');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isError
                        ? scheme.errorContainer.withValues(alpha: 0.5)
                        : scheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isError
                          ? scheme.error.withValues(alpha: 0.4)
                          : scheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        expression,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        resultText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: isError ? scheme.error : scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () => context.go(backPath),
                      child: const Text('Назад к форме'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('На главную'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _calcResult(Map<String, String> q) {
    final result = calculate(q['a'], q['op'], q['b']);
    return switch (result) {
      CalcSuccess(:final value) => formatNumber(value),
      CalcFailure(:final message) => 'Ошибка: $message',
    };
  }

  String _convertResult(Map<String, String> q) {
    final result = convert(q['amount'], q['from'], q['to']);
    return switch (result) {
      ConvertSuccess(:final value) => formatNumber(value),
      ConvertFailure(:final message) => 'Ошибка: $message',
    };
  }
}
