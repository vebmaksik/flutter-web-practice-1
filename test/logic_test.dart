import 'package:flutter_test/flutter_test.dart';
import 'package:calc_web/logic/calculator.dart';
import 'package:calc_web/logic/currency.dart';

void main() {
  group('Калькулятор', () {
    test('сложение', () {
      final r = calculate('2', '+', '3');
      expect(r, isA<CalcSuccess>());
      expect((r as CalcSuccess).value, 5.0);
    });

    test('вычитание', () {
      final r = calculate('10', '-', '4');
      expect((r as CalcSuccess).value, 6.0);
    });

    test('умножение', () {
      final r = calculate('3', '*', '4');
      expect((r as CalcSuccess).value, 12.0);
    });

    test('деление', () {
      final r = calculate('10', '/', '4');
      expect((r as CalcSuccess).value, 2.5);
    });

    test('деление на ноль даёт ошибку', () {
      final r = calculate('5', '/', '0');
      expect(r, isA<CalcFailure>());
      expect((r as CalcFailure).message, contains('Деление на ноль'));
    });

    test('нечисловой ввод даёт ошибку', () {
      final r = calculate('abc', '+', '2');
      expect(r, isA<CalcFailure>());
      expect((r as CalcFailure).message, contains('не числа'));
    });

    test('неизвестная операция даёт ошибку', () {
      final r = calculate('2', '%', '3');
      expect(r, isA<CalcFailure>());
      expect((r as CalcFailure).message, contains('Неизвестная'));
    });
  });

  group('Конвертер', () {
    test('конвертация RUB → USD', () {
      final r = convert('1000', 'RUB', 'USD');
      expect(r, isA<ConvertSuccess>());
      final expected = 1000 * currencyRates['RUB']! / currencyRates['USD']!;
      expect((r as ConvertSuccess).value, closeTo(expected, 0.01));
    });

    test('конвертация EUR → RUB', () {
      final r = convert('10', 'EUR', 'RUB');
      expect(r, isA<ConvertSuccess>());
      final expected = 10 * currencyRates['EUR']! / currencyRates['RUB']!;
      expect((r as ConvertSuccess).value, closeTo(expected, 0.01));
    });

    test('отрицательная сумма даёт ошибку', () {
      final r = convert('-5', 'RUB', 'USD');
      expect(r, isA<ConvertFailure>());
    });

    test('неизвестная валюта даёт ошибку', () {
      final r = convert('100', 'XXX', 'USD');
      expect(r, isA<ConvertFailure>());
    });

    test('нечисловая сумма даёт ошибку', () {
      final r = convert('abc', 'RUB', 'USD');
      expect(r, isA<ConvertFailure>());
    });
  });

  group('Форматирование', () {
    test('целое число без .0', () {
      expect(formatNumber(5.0), '5');
    });

    test('округление до 4 знаков', () {
      expect(formatNumber(3.3333333333333335), '3.3333');
    });
  });
}