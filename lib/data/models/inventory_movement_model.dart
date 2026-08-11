// lib/data/models/inventory_movement_model.dart

enum MovementType { entry, exit, adjustment, waste, internalConsumption, transfer }

class InventoryMovementModel {
  final String id;
  final String productId;
  final String productName;
  final MovementType type;
  final int quantity;
  final double unitCostUsd;
  final String reason;
  final String? evidencePhotoPath;
  final String authorizedBy;
  final DateTime timestamp;
  final Map<String, dynamic>? kardexSnapshot;

  InventoryMovementModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unitCostUsd,
    required this.reason,
    this.evidencePhotoPath,
    required this.authorizedBy,
    required this.timestamp,
    this.kardexSnapshot,
  });

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    return InventoryMovementModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      type: MovementType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      quantity: json['quantity'] ?? 0,
      unitCostUsd: json['unit_cost_usd']?.toDouble() ?? 0.0,
      reason: json['reason'],
      evidencePhotoPath: json['evidence_photo_path'],
      authorizedBy: json['authorized_by'],
      timestamp: DateTime.parse(json['timestamp']),
      kardexSnapshot: json['kardex_snapshot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'unit_cost_usd': unitCostUsd,
      'reason': reason,
      'evidence_photo_path': evidencePhotoPath,
      'authorized_by': authorizedBy,
      'timestamp': timestamp.toIso8601String(),
      'kardex_snapshot': kardexSnapshot,
    };
  }
}
