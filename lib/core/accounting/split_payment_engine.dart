// lib/core/accounting/split_payment_engine.dart

import '../accounting/fx_currency_engine.dart';

class PaymentFraction {
  final String method; // 'pago_movil', 'cash_usd', 'pos', 'zelle'
  final IsoCurrency currency;
  final double amountInOriginalCurrency;
  final double exchangeRate; // Tasa aplicada en ese segundo
  final String? referenceNumber;

  PaymentFraction({
    required this.method,
    required this.currency,
    required this.amountInOriginalCurrency,
    required this.exchangeRate,
    this.referenceNumber,
  });

  /// Convierte la fracción cobrada a la moneda base (VES)
  double get amountInBaseVes => amountInOriginalCurrency * exchangeRate;
}

class SplitPaymentEngine {
  /// Procesa y valida si la suma de los pagos fraccionados cubre el total de la factura
  static bool validateSplitPayment({
    required double totalInvoiceAmountVes,
    required List<PaymentFraction> fractions,
    double epsilon = 0.01, // Margen de tolerancia por redondeo
  }) {
    final double totalPaidVes = fractions.fold(
      0.0, 
      (sum, fraction) => sum + fraction.amountInBaseVes
    );

    return (totalPaidVes - totalInvoiceAmountVes).abs() <= epsilon || totalPaidVes >= totalInvoiceAmountVes;
  }

  /// Calcula el vuelto / cambio a entregar según la divisa preferida por el cliente
  static double calculateChange({
    required double totalInvoiceAmountVes,
    required List<PaymentFraction> fractions,
    required double targetCurrencyRate,
  }) {
    final double totalPaidVes = fractions.fold(
      0.0, 
      (sum, fraction) => sum + fraction.amountInBaseVes
    );

    final double changeInVes = totalPaidVes - totalInvoiceAmountVes;
    if (changeInVes <= 0) return 0.0;

    // Retorna el vuelto convertido a la moneda de entrega (ej. USD efectivo o VES)
    return changeInVes / targetCurrencyRate;
  }
}
