import 'package:decimal/decimal.dart';

enum CashRegisterType { mainVault, pettyCash } // Bóveda vs Caja Chica

class CashMovement {
  final String id;
  final String registerId;
  final String userId;
  final Decimal amountVes;
  final Decimal amountUsd;
  final String concept; // Ej: "Pago de flete", "Retiro a Bóveda", "Fondo Inicial"
  final bool isIncome;  // true = Ingreso, false = Egreso
  final DateTime timestamp;

  CashMovement({
    required this.id,
    required this.registerId,
    required this.userId,
    required this.amountVes,
    required this.amountUsd,
    required this.concept,
    required this.isIncome,
    required this.timestamp,
  });
}

class CashSession {
  final String sessionId;
  final String registerId;
  final String cashierUserId;
  final Decimal openingBalanceVes;
  final Decimal openingBalanceUsd;
  Decimal currentBalanceVes;
  Decimal currentBalanceUsd;
  final DateTime openedAt;
  DateTime? closedAt;
  bool isOpen;

  CashSession({
    required this.sessionId,
    required this.registerId,
    required this.cashierUserId,
    required this.openingBalanceVes,
    required this.openingBalanceUsd,
    required this.currentBalanceVes,
    required this.currentBalanceUsd,
    required this.openedAt,
    this.isOpen = true,
  });
}

class CashManagementEngine {
  /// Registra un movimiento en Caja Chica (Gastos menores o reabastecimiento)
  static CashSession processPettyExpense({
    required CashSession session,
    required Decimal amountVes,
    required Decimal amountUsd,
    required String concept,
    required String userId,
  }) {
    if (!session.isOpen) throw Exception('La caja está cerrada');

    session.currentBalanceVes -= amountVes;
    session.currentBalanceUsd -= amountUsd;

    return session;
  }

  /// Transferencia / Relevo de efectivo de Caja Chica a Caja Principal (Bóveda)
  static Map<String, Decimal> transferToVault({
    required CashSession pettySession,
    required Decimal transferVes,
    required Decimal transferUsd,
  }) {
    if (pettySession.currentBalanceVes < transferVes || pettySession.currentBalanceUsd < transferUsd) {
      throw Exception('Fondos insuficientes en Caja Chica para realizar la transferencia a Bóveda');
    }

    pettySession.currentBalanceVes -= transferVes;
    pettySession.currentBalanceUsd -= transferUsd;

    return {
      'vault_received_ves': transferVes,
      'vault_received_usd': transferUsd,
      'remaining_petty_ves': pettySession.currentBalanceVes,
      'remaining_petty_usd': pettySession.currentBalanceUsd,
    };
  }

  /// Realiza el Arqueo de Caja y calcula descuadres (Sobrantes o Faltantes)
  static Map<String, dynamic> performCashAudit({
    required CashSession session,
    required Decimal physicalCountVes,
    required Decimal physicalCountUsd,
  }) {
    final differenceVes = physicalCountVes - session.currentBalanceVes;
    final differenceUsd = physicalCountUsd - session.currentBalanceUsd;

    return {
      'expected_ves': session.currentBalanceVes,
      'counted_ves': physicalCountVes,
      'difference_ves': differenceVes, // Positivo = Sobrante, Negativo = Faltante
      'expected_usd': session.currentBalanceUsd,
      'counted_usd': physicalCountUsd,
      'difference_usd': differenceUsd,
      'is_balanced': (differenceVes == Decimal.zero && differenceUsd == Decimal.zero),
    };
  }
}
