// lib/core/reports/periodic_report_engine.dart

enum ReportTimeframe { daily, weekly, monthly, annual, custom }

class ReportDateFilter {
  final ReportTimeframe timeframe;
  final DateTime startDate;
  final DateTime endDate;

  ReportDateFilter._({
    required this.timeframe,
    required this.startDate,
    required this.endDate,
  });

  /// Creador para Reporte Diario (Hoy)
  factory ReportDateFilter.daily([DateTime? date]) {
    final target = date ?? DateTime.now();
    final start = DateTime(target.year, target.month, target.day, 0, 0, 0);
    final end = DateTime(target.year, target.month, target.day, 23, 59, 59);
    return ReportDateFilter._(timeframe: ReportTimeframe.daily, startDate: start, endDate: end);
  }

  /// Creador para Reporte Semanal (Últimos 7 días)
  factory ReportDateFilter.weekly([DateTime? date]) {
    final target = date ?? DateTime.now();
    final start = target.subtract(const Duration(days: 6));
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(target.year, target.month, target.day, 23, 59, 59);
    return ReportDateFilter._(timeframe: ReportTimeframe.weekly, startDate: startDate, endDate: endDate);
  }

  /// Creador para Reporte Mensual (Mes actual o seleccionado)
  factory ReportDateFilter.monthly([int? year, int? month]) {
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    final startDate = DateTime(targetYear, targetMonth, 1, 0, 0, 0);
    final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
    final endDate = DateTime(targetYear, targetMonth, lastDay, 23, 59, 59);

    return ReportDateFilter._(timeframe: ReportTimeframe.monthly, startDate: startDate, endDate: endDate);
  }

  /// Creador para Reporte Anual (Año completo)
  factory ReportDateFilter.annual([int? year]) {
    final targetYear = year ?? DateTime.now().year;
    final startDate = DateTime(targetYear, 1, 1, 0, 0, 0);
    final endDate = DateTime(targetYear, 12, 31, 23, 59, 59);

    return ReportDateFilter._(timeframe: ReportTimeframe.annual, startDate: startDate, endDate: endDate);
  }

  /// Creador para Rango de Fechas Personalizado
  factory ReportDateFilter.custom(DateTime start, DateTime end) {
    return ReportDateFilter._(
      timeframe: ReportTimeframe.custom,
      startDate: DateTime(start.year, start.month, start.day, 0, 0, 0),
      endDate: DateTime(end.year, end.month, end.day, 23, 59, 59),
    );
  }
}

class PeriodicConsolidatedReport {
  final ReportTimeframe timeframe;
  final DateTime startDate;
  final DateTime endDate;
  final int totalSalesCount;
  final double grossRevenueUsd;
  final double grossRevenueVes;
  final double totalCostUsd;
  final double grossProfitUsd;
  final double profitMarginPercentage;
  final double totalIvaCollectedVes;
  final double totalIgtfCollectedVes;

  PeriodicConsolidatedReport({
    required this.timeframe,
    required this.startDate,
    required this.endDate,
    required this.totalSalesCount,
    required this.grossRevenueUsd,
    required this.grossRevenueVes,
    required this.totalCostUsd,
    required this.grossProfitUsd,
    required this.profitMarginPercentage,
    required this.totalIvaCollectedVes,
    required this.totalIgtfCollectedVes,
  });
}

class PeriodicReportEngine {
  /// Genera el reporte consolidado filtrando las transacciones según el periodo elegido
  static PeriodicConsolidatedReport generateReport({
    required List<Map<String, dynamic>> allTransactions,
    required ReportDateFilter filter,
  }) {
    final filtered = allTransactions.where((tx) {
      final txDate = DateTime.parse(tx['created_at']);
      return txDate.isAfter(filter.startDate) && txDate.isBefore(filter.endDate);
    }).toList();

    double revenueUsd = 0;
    double revenueVes = 0;
    double costUsd = 0;
    double ivaVes = 0;
    double igtfVes = 0;

    for (var tx in filtered) {
      revenueUsd += (tx['total_usd'] as num?)?.toDouble() ?? 0.0;
      revenueVes += (tx['total_ves'] as num?)?.toDouble() ?? 0.0;
      costUsd += (tx['cost_usd'] as num?)?.toDouble() ?? 0.0;
      ivaVes += (tx['tax_ves'] as num?)?.toDouble() ?? 0.0;
      igtfVes += (tx['igtf_ves'] as num?)?.toDouble() ?? 0.0;
    }

    final double grossProfitUsd = revenueUsd - costUsd;
    final double margin = revenueUsd > 0 ? (grossProfitUsd / revenueUsd) * 100.0 : 0.0;

    return PeriodicConsolidatedReport(
      timeframe: filter.timeframe,
      startDate: filter.startDate,
      endDate: filter.endDate,
      totalSalesCount: filtered.length,
      grossRevenueUsd: double.parse(revenueUsd.toStringAsFixed(2)),
      grossRevenueVes: double.parse(revenueVes.toStringAsFixed(2)),
      totalCostUsd: double.parse(costUsd.toStringAsFixed(2)),
      grossProfitUsd: double.parse(grossProfitUsd.toStringAsFixed(2)),
      profitMarginPercentage: double.parse(margin.toStringAsFixed(2)),
      totalIvaCollectedVes: double.parse(ivaVes.toStringAsFixed(2)),
      totalIgtfCollectedVes: double.parse(igtfVes.toStringAsFixed(2)),
    );
  }
}
