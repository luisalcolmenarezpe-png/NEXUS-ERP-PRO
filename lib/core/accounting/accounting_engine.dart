// lib/core/accounting/accounting_engine.dart

import '../models/transaction_model.dart';

class AccountingEngine {
  /// Calcula el total general de una lista de transacciones sin errores de sintaxis
  double calculateGrandTotal(List<TransactionModel> transactions) {
    double grandTotal = 0.0;
    for (var tx in transactions) {
      grandTotal += tx.amount; // Variable corregida (grandTotal)
    }
    return grandTotal;
  }

  /// Registro de partida doble (Débito y Crédito deben cuadrar)
  bool validateDoubleEntry({
    required double totalDebit,
    required double totalCredit,
  }) {
    const double epsilon = 0.001; // Tolerancia por redondeo
    return (totalDebit - totalCredit).abs() < epsilon;
  }
}
