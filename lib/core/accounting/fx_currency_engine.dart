// lib/core/accounting/fx_currency_engine.dart

import 'package:decimal/decimal.dart';

enum IsoCurrency { VES, USD, EUR, COP }

class FxTransactionRecord {
  final String id;
  final Decimal amountBaseCurrency; // Generalmente VES
  final Decimal amountForeignCurrency;
  final IsoCurrency foreignCurrency;
  final Decimal exchangeRateAtTransaction; // Tasa BCV del momento
  final DateTime timestamp;

  FxTransactionRecord({
    required this.id,
    required this.amountBaseCurrency,
    required this.amountForeignCurrency,
    required this.foreignCurrency,
    required this.exchangeRateAtTransaction,
    required this.timestamp,
  });
}

class FxCurrencyEngine {
  /// Convierte monto de divisa extranjera a moneda base al tipo de cambio BCV
  static Decimal convertToFieldCurrency({
    required Decimal foreignAmount,
    required Decimal bcvRate,
  }) {
    return foreignAmount * bcvRate;
  }

  /// Calula la Pérdida o Ganancia por Diferencial Cambiario (FX Gain/Loss)
  static Decimal calculateFxGainOrLoss({
    required Decimal foreignAmount,
    required Decimal originalExchangeRate,
    required Decimal settlementExchangeRate,
  }) {
    final originalBaseVal = foreignAmount * originalExchangeRate;
    final settlementBaseVal = foreignAmount * settlementExchangeRate;
    
    // Positivo = Ganancia por diferencial, Negativo = Pérdida
    return settlementBaseVal - originalBaseVal;
  }
}
