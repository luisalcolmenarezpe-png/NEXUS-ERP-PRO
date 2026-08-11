// lib/data/models/closure_model.dart

class ClosureModel {
  final String id;
  final String sessionId;
  final String cashierId;
  final String cashierName;
  final DateTime openedAt;
  final DateTime closedAt;
  final double openingBalanceVes;
  final double openingBalanceUsd;
  final double closingBalanceVes;
  final double closingBalanceUsd;
  final double expectedBalanceVes;
  final double expectedBalanceUsd;
  final double totalSalesVes;
  final double totalSalesUsd;
  final int transactionCount;
  final double bankDepositTotal;
  final double retentionTaxAmount;
  final double healthContributionAmount;
  final double netAfterDeductions;
  final List<Map<String, dynamic>> paymentBreakdown;
  final String? notes;

  ClosureModel({
    required this.id,
    required this.sessionId,
    required this.cashierId,
    required this.cashierName,
    required this.openedAt,
    required this.closedAt,
    required this.openingBalanceVes,
    required this.openingBalanceUsd,
    required this.closingBalanceVes,
    required this.closingBalanceUsd,
    required this.expectedBalanceVes,
    required this.expectedBalanceUsd,
    required this.totalSalesVes,
    required this.totalSalesUsd,
    required this.transactionCount,
    required this.bankDepositTotal,
    required this.retentionTaxAmount,
    required this.healthContributionAmount,
    required this.netAfterDeductions,
    this.paymentBreakdown = const [],
    this.notes,
  });

  double get differenceVes => closingBalanceVes - expectedBalanceVes;
  double get differenceUsd => closingBalanceUsd - expectedBalanceUsd;

  String get status {
    if (differenceVes < 0 || differenceUsd < 0) return 'FALTANTE';
    if (differenceVes > 0 || differenceUsd > 0) return 'SOBRANTE';
    return 'CUADRA';
  }

  factory ClosureModel.fromJson(Map<String, dynamic> json) {
    return ClosureModel(
      id: json['id'],
      sessionId: json['session_id'],
      cashierId: json['cashier_id'],
      cashierName: json['cashier_name'],
      openedAt: DateTime.parse(json['opened_at']),
      closedAt: DateTime.parse(json['closed_at']),
      openingBalanceVes: json['opening_balance_ves']?.toDouble() ?? 0.0,
      openingBalanceUsd: json['opening_balance_usd']?.toDouble() ?? 0.0,
      closingBalanceVes: json['closing_balance_ves']?.toDouble() ?? 0.0,
      closingBalanceUsd: json['closing_balance_usd']?.toDouble() ?? 0.0,
      expectedBalanceVes: json['expected_balance_ves']?.toDouble() ?? 0.0,
      expectedBalanceUsd: json['expected_balance_usd']?.toDouble() ?? 0.0,
      totalSalesVes: json['total_sales_ves']?.toDouble() ?? 0.0,
      totalSalesUsd: json['total_sales_usd']?.toDouble() ?? 0.0,
      transactionCount: json['transaction_count'] ?? 0,
      bankDepositTotal: json['bank_deposit_total']?.toDouble() ?? 0.0,
      retentionTaxAmount: json['retention_tax_amount']?.toDouble() ?? 0.0,
      healthContributionAmount: json['health_contribution_amount']?.toDouble() ?? 0.0,
      netAfterDeductions: json['net_after_deductions']?.toDouble() ?? 0.0,
      paymentBreakdown: List<Map<String, dynamic>>.from(json['payment_breakdown'] ?? []),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'opened_at': openedAt.toIso8601String(),
      'closed_at': closedAt.toIso8601String(),
      'opening_balance_ves': openingBalanceVes,
      'opening_balance_usd': openingBalanceUsd,
      'closing_balance_ves': closingBalanceVes,
      'closing_balance_usd': closingBalanceUsd,
      'expected_balance_ves': expectedBalanceVes,
      'expected_balance_usd': expectedBalanceUsd,
      'total_sales_ves': totalSalesVes,
      'total_sales_usd': totalSalesUsd,
      'transaction_count': transactionCount,
      'bank_deposit_total': bankDepositTotal,
      'retention_tax_amount': retentionTaxAmount,
      'health_contribution_amount': healthContributionAmount,
      'net_after_deductions': netAfterDeductions,
      'status': status,
      'payment_breakdown': paymentBreakdown,
      'notes': notes,
    };
  }
}
