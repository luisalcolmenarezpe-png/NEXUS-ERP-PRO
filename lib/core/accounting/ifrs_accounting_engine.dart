// lib/core/accounting/ifrs_accounting_engine.dart

enum IfrsAccountCategory { asset, liability, equity, revenue, expense }

class IfrsAccount {
  final String code; // Ej: 1.1.01.01
  final String name;
  final IfrsAccountCategory category;
  double balance;

  IfrsAccount({
    required this.code,
    required this.name,
    required this.category,
    this.balance = 0.0,
  });
}

class IfrsAccountingEngine {
  /// Genera la estructura básica del Balance General bajo normas NIIF
  Map<String, double> generateIfrsBalanceSheet(List<IfrsAccount> accounts) {
    double totalAssets = 0.0;
    double totalLiabilities = 0.0;
    double totalEquity = 0.0;

    for (var acc in accounts) {
      switch (acc.category) {
        case IfrsAccountCategory.asset:
          totalAssets += acc.balance;
          break;
        case IfrsAccountCategory.liability:
          totalLiabilities += acc.balance;
          break;
        case IfrsAccountCategory.equity:
          totalEquity += acc.balance;
          break;
        default:
          break;
      }
    }

    return {
      'total_assets': totalAssets,
      'total_liabilities': totalLiabilities,
      'total_equity': totalEquity,
      'equation_check': totalAssets - (totalLiabilities + totalEquity), // Debe ser 0.0
    };
  }
}
