// lib/core/inventory/inventory_intelligence_engine.dart

enum AbcCategory { A, B, C }

class InventoryItemStats {
  final String productId;
  final double totalRevenue;
  double cumulativePercentage = 0.0;
  AbcCategory category = AbcCategory.C;

  InventoryItemStats({
    required this.productId,
    required this.totalRevenue,
  });
}

class InventoryIntelligenceEngine {
  /// Calcula el Inventario de Seguridad (Safety Stock)
  double calculateSafetyStock({
    required double maxDailySales,
    required double maxLeadTimeDays,
    required double avgDailySales,
    required double avgLeadTimeDays,
  }) {
    final safetyStock = (maxDailySales * maxLeadTimeDays) - (avgDailySales * avgLeadTimeDays);
    return safetyStock > 0 ? safetyStock : 0.0;
  }

  /// Calcula el Punto de Reorden (Reorder Point - ROP)
  double calculateReorderPoint({
    required double avgDailySales,
    required double leadTimeDays,
    required double safetyStock,
  }) {
    return (avgDailySales * leadTimeDays) + safetyStock;
  }

  /// Clasificación ABC de Inventario (Regla del 80/20)
  List<InventoryItemStats> performAbcAnalysis(List<InventoryItemStats> items) {
    if (items.isEmpty) return items;

    // Ordenar de mayor a menor ingreso
    items.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final double totalRevenue = items.fold(0.0, (sum, item) => sum + item.totalRevenue);
    if (totalRevenue == 0) return items;

    double runningTotal = 0.0;

    for (var item in items) {
      runningTotal += item.totalRevenue;
      item.cumulativePercentage = (runningTotal / totalRevenue) * 100;

      if (item.cumulativePercentage <= 80) {
        item.category = AbcCategory.A;
      } else if (item.cumulativePercentage <= 95) {
        item.category = AbcCategory.B;
      } else {
        item.category = AbcCategory.C;
      }
    }

    return items;
  }

  /// Predicción de riesgo de merma por vencimiento cercano
  bool isAtRiskOfExpiration({
    required DateTime expirationDate,
    required int warningDaysThreshold,
  }) {
    final daysUntilExpiry = expirationDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= warningDaysThreshold;
  }
}
