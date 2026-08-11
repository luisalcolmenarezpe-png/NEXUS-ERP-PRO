// lib/core/hardware/pci_payment_tokenizer.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';

class PciPaymentTokenizer {
  /// Enmascara tarjetas para pantalla/recibo cumpliendo la norma PCI-DSS (Muestra solo últimos 4 dígitos)
  static String maskPan(String fullPan) {
    final cleanPan = fullPan.replaceAll(RegExp(r'\D'), '');
    if (cleanPan.length < 12) return '****';
    final last4 = cleanPan.substring(cleanPan.length - 4);
    return '****-****-****-$last4';
  }

  /// Genera un token irreversible de la transacción (Evita almacenar números de tarjeta en disco)
  static String generatePaymentToken({
    required String rawPan,
    required String cardHolder,
    required String expiryDate,
    required String salt,
  }) {
    final payload = '$rawPan|$cardHolder|$expiryDate|$salt';
    return sha256.convert(utf8.encode(payload)).toString();
  }
}
