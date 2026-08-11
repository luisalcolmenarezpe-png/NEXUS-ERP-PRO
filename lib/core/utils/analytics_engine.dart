// lib/core/utils/analytics_engine.dart

import '../models/transaction_model.dart';

class ProductSalesMetric {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;

  ProductSalesMetric({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
  });
}

class AnalyticsEngine {
  /// Calcula el Ingreso Bruto total acumulado en una lista de transacciones
  static double calculateGrossRevenue(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return 0.0;
    return transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Calcula el Ticket Promedio por venta realizada
  static double calculateAverageTicketSize(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return 0.0;
    final totalRevenue = calculateGrossRevenue(transactions);
    return totalRevenue / transactions.length;
  }

  /// Desglosa el volumen de ingresos por Método de Pago (Pago Móvil, Efectivo, Tarjeta, Divisa)
  static Map<String, double> getRevenueByPaymentMethod(List<TransactionModel> transactions) {
    final Map<String, double> breakdown = {};
    for (var tx in transactions) {
      final method = tx.paymentMethod.isNotEmpty ? tx.paymentMethod : 'Otros';
      breakdown[method] = (breakdown[method] ?? 0.0) + tx.amount;
    }
    return breakdown;
  }

  /// Identifica los productos más vendidos (Top Sellers / Rotación)
  static List<ProductSalesMetric> getTopSellingProducts({
    required List<Map<String, dynamic>> salesItems,
    int limit = 5,
  }) {
    final Map<String, ProductSalesMetric> metricsMap = {};

    for (var item in salesItems) {
      final id = item['id']?.toString() ?? 'unknown';
      final name = item['name']?.toString() ?? 'Producto Desconocido';
      final qty = (item['qty'] as num?)?.toInt() ?? 1;
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;

      if (metricsMap.containsKey(id)) {
        final existing = metricsMap[id]!;
        metricsMap[id] = ProductSalesMetric(
          productId: id,
          productName: name,
          quantitySold: existing.quantitySold + qty,
          totalRevenue: existing.totalRevenue + (qty * price),
        );
      } else {
        metricsMap[id] = ProductSalesMetric(
          productId: id,
          productName: name,
          quantitySold: qty,
          totalRevenue: qty * price,
        );
      }
    }

    final sortedList = metricsMap.values.toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    return sortedList.take(limit).toList();
  }

  /// Calcula el Margen Neto de Ganancia (%) descontando costos y gastos operativos
  static double calculateNetProfitMargin({
    required double totalRevenue,
    required double totalCostOfGoodsSold,
    required double operatingExpenses,
  }) {
    if (totalRevenue <= 0) return 0.0;
    final netProfit = totalRevenue - totalCostOfGoodsSold - operatingExpenses;
    return (netProfit / totalRevenue) * 100;
  }
}
