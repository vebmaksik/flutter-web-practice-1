import 'package:shared_preferences/shared_preferences.dart';

const currencyRates = <String, double>{
  'RUB': 1.0,
  'USD': 82.5,
  'EUR': 90.3,
  'GBP': 107.8,
  'CNY': 12.7,
  'KZT': 0.17,
};

const currencyNames = <String, String>{
  'RUB': 'Российский рубль',
  'USD': 'Доллар США',
  'EUR': 'Евро',
  'GBP': 'Фунт стерлингов',
  'CNY': 'Китайский юань',
  'KZT': 'Казахстанский тенге',
};

sealed class ConvertResult {
  const ConvertResult();
}

class ConvertSuccess extends ConvertResult {
  final double value;
  const ConvertSuccess(this.value);
}

class ConvertFailure extends ConvertResult {
  final String message;
  const ConvertFailure(this.message);
}

ConvertResult convert(String? rawAmount, String? from, String? to) {
  final amount = double.tryParse(rawAmount?.replaceAll(',', '.') ?? '');
  if (amount == null) {
    return const ConvertFailure('Сумма должна быть числом');
  }
  if (amount < 0) {
    return const ConvertFailure('Сумма не может быть отрицательной');
  }
  final fromRate = currencyRates[from];
  final toRate = currencyRates[to];
  if (fromRate == null || toRate == null) {
    return const ConvertFailure('Неизвестная валюта');
  }
  return ConvertSuccess(amount * fromRate / toRate);
}

Future<void> saveLastPair(String from, String to) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_from', from);
  await prefs.setString('last_to', to);
}

Future<(String, String)> loadLastPair() async {
  final prefs = await SharedPreferences.getInstance();
  return (
    prefs.getString('last_from') ?? 'RUB',
    prefs.getString('last_to') ?? 'USD',
  );
}
