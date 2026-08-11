// lib/core/accounting/devaluation_shield_engine.dart

enum DevaluationRiskLevel { low, moderate, critical }

class DevaluationAnalysis {
  final double previousRate;
  final double currentRate;
  final double percentageIncrease;
  final DevaluationRiskLevel riskLevel;
  final double vesExposedAmount; // Bs. en caja + Bs. por cobrar
  final double lossInUsd;        // Dólares perdidos por la subida de tasa
  final List<String> recommendedActions;

  DevaluationAnalysis({
    required this.previousRate,
    required this.currentRate,
    required this.percentageIncrease,
    required this.riskLevel,
    required this.vesExposedAmount,
    required this.lossInUsd,
    required this.recommendedActions,
  });
}

class DevaluationShieldEngine {
  /// Analiza el impacto del aumento del dólar sobre la liquidez del negocio
  static DevaluationAnalysis evaluateDevaluationImpact({
    required double previousRateVes,
    required double currentRateVes,
    required double vesInPettyCash,
    required double vesInAccountsReceivable, // Cuentas por cobrar en Bs.
  }) {
    if (previousRateVes <= 0 || currentRateVes <= 0) {
      throw ArgumentError('Las tasas de cambio deben ser mayores a cero.');
    }

    final double rateDelta = currentRateVes - previousRateVes;
    final double percentageIncrease = (rateDelta / previousRateVes) * 100.0;

    final double totalVesExposed = vesInPettyCash + vesInAccountsReceivable;

    // Valor anterior en USD vs Valor actual en USD de los mismos bolívares
    final double previousValueUsd = totalVesExposed / previousRateVes;
    final double currentValueUsd = totalVesExposed / currentRateVes;
    final double lossInUsd = previousValueUsd - currentValueUsd;

    DevaluationRiskLevel riskLevel;
    List<String> actions = [];

    if (percentageIncrease < 1.5) {
      riskLevel = DevaluationRiskLevel.low;
      actions.add('Variación normal de tasa. No se requieren ajustes de emergencia.');
    } else if (percentageIncrease >= 1.5 && percentageIncrease < 4.0) {
      riskLevel = DevaluationRiskLevel.moderate;
      actions.add('Alerta de devaluación moderada.');
      actions.add('Priorice el cobro inmediato de cuentas por cobrar en Bs.');
      actions.add('Considere usar bolívares en caja chica para comprar mercancía de alta rotación.');
    } else {
      riskLevel = DevaluationRiskLevel.critical;
      actions.add('ALERTA CRÍTICA: Salto abrupto en la tasa de cambio.');
      actions.add('Indexar inmediatamente todas las cuentas por cobrar al tipo de cambio del día.');
      actions.add('Convertir excedentes de bolívares a divisas o pagar facturas de proveedores pendientes.');
    }

    return DevaluationAnalysis(
      previousRate: previousRateVes,
      currentRate: currentRateVes,
      percentageIncrease: double.parse(percentageIncrease.toStringAsFixed(2)),
      riskLevel: riskLevel,
      vesExposedAmount: totalVesExposed,
      lossInUsd: double.parse(lossInUsd.toStringAsFixed(2)),
      recommendedActions: actions,
    );
  }

  /// Ajusta automáticamente los precios de venta en Bs conservando el margen en $ USD
  static double calculateDynamicPriceVes({
    required double priceInUsd,
    required double activeExchangeRate,
  }) {
    return double.parse((priceInUsd * activeExchangeRate).toStringAsFixed(2));
  }
}
