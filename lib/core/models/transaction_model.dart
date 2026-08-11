class PosTransactionModel {
  final String id;
  final String? clientId;
  final double totalAmount;
  final double taxAmount;
  final double discountAmount;
  final String status;
  final String syncStatus;
  final String createdAt;
  final String? syncedAt;
  
  // Relational data
  final List<PosTransactionLineModel>? lines;

  PosTransactionModel({
    required this.id,
    this.clientId,
    required this.totalAmount,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.status,
    this.syncStatus = 'pending_sync',
    required this.createdAt,
    this.syncedAt,
    this.lines,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'total_amount': totalAmount,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'status': status,
      'sync_status': syncStatus,
      'created_at': createdAt,
      'synced_at': syncedAt,
    };
  }

  factory PosTransactionModel.fromMap(Map<String, dynamic> map, {List<PosTransactionLineModel>? lines}) {
    return PosTransactionModel(
      id: map['id'] as String,
      clientId: map['client_id'] as String?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      taxAmount: (map['tax_amount'] as num).toDouble(),
      discountAmount: (map['discount_amount'] as num).toDouble(),
      status: map['status'] as String,
      syncStatus: map['sync_status'] as String,
      createdAt: map['created_at'] as String,
      syncedAt: map['synced_at'] as String?,
      lines: lines,
    );
  }
}

class PosTransactionLineModel {
  final String id;
  final String transactionId;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double subtotal;

  PosTransactionLineModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory PosTransactionLineModel.fromMap(Map<String, dynamic> map) {
    return PosTransactionLineModel(
      id: map['id'] as String,
      transactionId: map['transaction_id'] as String,
      productId: map['product_id'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }
}
