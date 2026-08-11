// lib/core/accounting/financial_integrity_engine.dart

enum InventoryReconciliationStatus { cuadra, sobrante, faltante }

class InventoryReconciliation {
  final double initialStock;
  final double purchases;
  final double sales;
  final double waste;
  final double internalConsumption;
  final double physicalCount;

  InventoryReconciliation({
    required this.initialStock,
    required this.purchases,
    required this.sales,
    required this.waste,
    required this.internalConsumption,
    required this.physicalCount,
  });
}

class FinancialClosingAudit {
  final double cashExpected;
  final double cashActual;
  final double bankDeposits;
  final double shortageAmount;
  final double retentionTax;
  final double healthContribution;
  final double netAfterDeductions;

  FinancialClosingAudit({
    required this.cashExpected,
    required this.cashActual,
    required this.bankDeposits,
    required this.shortageAmount,
    required this.retentionTax,
    required this.healthContribution,
    required this.netAfterDeductions,
  });
}

class FinancialIntegrityEngine {
  /// Conciliación estricta de inventario
  static Map<String, dynamic> reconcileInventory(InventoryReconciliation data) {
    double theoretical = data.initialStock + data.purchases - (data.sales + data.waste + data.internalConsumption);
    double difference = data.physicalCount - theoretical;
    
    InventoryReconciliationStatus status = InventoryReconciliationStatus.cuadra;
    if (difference > 0) status = InventoryReconciliationStatus.sobrante;
    if (difference < 0) status = InventoryReconciliationStatus.faltante;
    
    return {
      'theoretical': theoretical,
      'difference': difference,
      'status': status,
    };
  }

  /// Validación de mermas con tope máximo de 10%
  static bool validateWasteThreshold(double totalSales, double totalWaste) {
    if (totalSales == 0) return true;
    double wastePercentage = (totalWaste / totalSales) * 100;
    return wastePercentage <= 10.0;
  }

  /// Auditoría de Cierre Financiero
  static FinancialClosingAudit auditFinancialClosing({
    required double cashExpected,
    required double cashActual,
    required double bankDeposits,
    required double totalRevenue,
  }) {
    double shortage = cashExpected - cashActual;
    if (shortage < 0) shortage = 0; // Sobrante
    
    double retention = totalRevenue * 0.0076;
    double health = totalRevenue * 0.01;
    double net = totalRevenue - retention - health;
    
    return FinancialClosingAudit(
      cashExpected: cashExpected,
      cashActual: cashActual,
      bankDeposits: bankDeposits,
      shortageAmount: shortage,
      retentionTax: retention,
      healthContribution: health,
      netAfterDeductions: net,
    );
  }
  
  static double calculateNetAfterDeductions(double grossAmount) {
    return grossAmount - (grossAmount * 0.0076) - (grossAmount * 0.01);
  }
}
