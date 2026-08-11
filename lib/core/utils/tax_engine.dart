/// core/utils/tax_engine.dart
/// Motor fiscal y de precios adaptado para normativas de cumplimiento (SENIAT / SUNDDE)
class TaxEngine {
  static const double defaultVatRate = 0.16; // 16% IVA estándar
  static const double igtfRate = 0.03;      // 3% IGTF para pagos en divisa/cripto
  static const double maxProfitMargin = 0.30; // Límite legal del 30% (SUNDDE)

  /// Calcula los impuestos aplicables a un monto base
  static Map<String, double> calculateTaxes({
    required double baseAmount,
    double customVatRate = defaultVatRate,
    bool applyIgtf = false,
  }) {
    final vatAmount = baseAmount * customVatRate;
    final subtotal = baseAmount + vatAmount;
    final igtfAmount = applyIgtf ? subtotal * igtfRate : 0.0;
    final total = subtotal + igtfAmount;

    return {
      'baseAmount': baseAmount,
      'vatAmount': vatAmount,
      'subtotal': subtotal,
      'igtfAmount': igtfAmount,
      'total': total,
    };
  }

  /// Valida que el precio de venta propuesto no viole el límite legal del 30%
  static bool validateProfitMargin({
    required double costPrice,
    required double sellingPrice,
  }) {
    if (costPrice <= 0) return false;
    final margin = (sellingPrice - costPrice) / costPrice;
    // Se añade un margen mínimo de tolerancia por decimales (0.01%)
    return margin <= (maxProfitMargin + 0.0001);
  }

  /// Calcula de forma automática el precio máximo legal permitido
  static double calculateMaxLegalPrice(double costPrice) {
    return costPrice * (1.0 + maxProfitMargin);
  }

  /// Realiza la conversión multimoneda basada en la tasa oficial del BCV
  static double convertCurrency({
    required double amount,
    required double bcvRate,
    required bool toBolivares,
  }) {
    if (bcvRate <= 0) return 0.0;
    if (toBolivares) {
      return amount * bcvRate; // Divisa a Bolívares
    } else {
      return amount / bcvRate; // Bolívares a Divisa
    }
  }
}
