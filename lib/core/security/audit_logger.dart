// lib/core/security/audit_logger.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';

enum AuditAction {
  login,
  logout,
  voidInvoice,
  priceChange,
  roleChange,
  taxConfigChange,
}

class AuditLogEntry {
  final String id;
  final String userId;
  final AuditAction action;
  final String details;
  final DateTime timestamp;
  final String previousHash;
  final String currentHash;

  AuditLogEntry({
    required this.id,
    required this.userId,
    required this.action,
    required this.details,
    required this.timestamp,
    required this.previousHash,
    required this.currentHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action.name,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'previous_hash': previousHash,
      'current_hash': currentHash,
    };
  }
}

class AuditLogger {
  /// Genera el hash criptográfico inmutable SHA-256 para el encadenamiento
  static String calculateHash({
    required String id,
    required String userId,
    required String action,
    required String details,
    required String timestamp,
    required String previousHash,
  }) {
    final rawData = '$id|$userId|$action|$details|$timestamp|$previousHash';
    return sha256.convert(utf8.encode(rawData)).toString();
  }

  /// Crea una nueva entrada de auditoría verificada con Hash Chaining
  AuditLogEntry createLogEntry({
    required String id,
    required String userId,
    required AuditAction action,
    required String details,
    required String previousHash,
  }) {
    final timestamp = DateTime.now();
    final currentHash = calculateHash(
      id: id,
      userId: userId,
      action: action.name,
      details: details,
      timestamp: timestamp.toIso8601String(),
      previousHash: previousHash,
    );

    return AuditLogEntry(
      id: id,
      userId: userId,
      action: action,
      details: details,
      timestamp: timestamp,
      previousHash: previousHash,
      currentHash: currentHash,
    );
  }
}
