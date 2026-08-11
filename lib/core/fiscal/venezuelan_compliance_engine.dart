// lib/core/fiscal/venezuelan_compliance_engine.dart

class VenezuelanComplianceEngine {
  /// Validante de RIF según estándar oficial del SENIAT (J, V, G, E, P)
  static bool isValidRif(String rif) {
    final cleanRif = rif.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
    if (!RegExp(r'^[JVGEP]\d{9}$').hasMatch(cleanRif)) return false;

    final letter = cleanRif[0];
    final numbers = cleanRif.substring(1, 9).split('').map(int.parse).toList();
    final checkDigit = int.parse(cleanRif[9]);

    int letterValue;
    switch (letter) {
      case 'V': letterValue = 1; break;
      case 'E': letterValue = 2; break;
      case 'J': letterValue = 3; break;
      case 'P': letterValue = 4; break;
      case 'G': letterValue = 5; break;
      default: return false;
    }

    final multipliers = [3, 2, 7, 6, 5, 4, 3, 2];
    int sum = letterValue * 4;
    for (int i = 0; i < 8; i++) {
      sum += numbers[i] * multipliers[i];
    }

    int remainder = sum % 11;
    int calculatedDigit = 11 - remainder;
    if (calculatedDigit >= 10) calculatedDigit = 0;

    return calculatedDigit == checkDigit;
  }

  /// Validación de Margen Máximo de Ganancia SUNDDE (Ley Orgánica de Precios Justos - Máx 30%)
  static bool validateSunddeMargin({
    required double unitCost,
    required double salePriceExcludingTax,
    double maxMarginPercentage = 30.0,
  }) {
    if (unitCost <= 0) return false;
    final profit = salePriceExcludingTax - unitCost;
    final margin = (profit / salePriceExcludingTax) * 100;
    return margin <= maxMarginPercentage;
  }

  /// Cálculo del Impuesto a las Grandes Transacciones Financieras (IGTF - 3%)
  static double calculateIgtf({
    required double amountInForeignCurrency,
    double igtfRate = 0.03, // 3%
  }) {
    if (amountInForeignCurrency <= 0) return 0.0;
    return amountInForeignCurrency * igtfRate;
  }

  /// Validación de estructura de Pago Móvil / C2P conforme a SUDEBAN
  static bool validateSudebanPagoMovil({
    required String bankCode,     // Ej: "0102"
    required String phoneNumber,  // Ej: "04141234567"
    required String reference,    // Mínimo 6 dígitos
  }) {
    final isBankValid = RegExp(r'^\d{4}$').hasMatch(bankCode);
    final isPhoneValid = RegExp(r'^04(12|14|24|16|26)\d{7}$').hasMatch(phoneNumber);
    final isRefValid = RegExp(r'^\d{6,8}$').hasMatch(reference);

    return isBankValid && isPhoneValid && isRefValid;
  }
}
