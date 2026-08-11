// lib/core/crm/crm_engine.dart

class CrmEngine {
  /// Valida si un cliente puede recibir crédito ("fiao") según su límite disponible
  bool canGrantCredit({
    required double currentBalance,
    required double newPurchaseAmount,
    required double maxCreditLimit,
  }) {
    return (currentBalance + newPurchaseAmount) <= maxCreditLimit;
  }

  /// Calcula el Credit Score del cliente (Escala de 0 a 100)
  int calculateCreditScore({
    required int totalTransactions,
    required int onTimePayments,
    required int latePayments,
    required int defaultedPayments,
  }) {
    if (totalTransactions == 0) return 50; // Puntaje inicial neutro

    double score = 100.0;
    score -= (latePayments / totalTransactions) * 35.0;
    score -= (defaultedPayments / totalTransactions) * 75.0;

    return score.clamp(0.0, 100.0).round();
  }

  /// Calcula los puntos de fidelización ganados por una compra
  int calculateEarnedPoints({
    required double purchaseAmount,
    double pointsPerCurrencyUnit = 0.1, // Ej: 1 punto por cada $10 o Bs 10
  }) {
    if (purchaseAmount <= 0) return 0;
    return (purchaseAmount * pointsPerCurrencyUnit).floor();
  }

  /// Convierte puntos de fidelidad acumulados a su equivalente monetario
  double pointsToMonetaryValue({
    required int points,
    required double conversionRate, // Valor monetario de 1 punto
  }) {
    return points * conversionRate;
  }
}
