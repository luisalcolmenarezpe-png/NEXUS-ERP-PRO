// lib/data/models/supplier_model.dart

class SupplierModel {
  final String id;
  final String rif;
  final String businessName;
  final String contactName;
  final String phone;
  final String email;
  final String address;
  final int creditDays;
  final double ivaRetentionPercent;
  final double islrRetentionPercent;
  final bool isSpecialContributor;
  final bool isActive;
  final DateTime createdAt;

  SupplierModel({
    required this.id,
    required this.rif,
    required this.businessName,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.address,
    required this.creditDays,
    required this.ivaRetentionPercent,
    required this.islrRetentionPercent,
    required this.isSpecialContributor,
    this.isActive = true,
    required this.createdAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      rif: json['rif'],
      businessName: json['business_name'],
      contactName: json['contact_name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      creditDays: json['credit_days'] ?? 0,
      ivaRetentionPercent: json['iva_retention_percent']?.toDouble() ?? 0.75,
      islrRetentionPercent: json['islr_retention_percent']?.toDouble() ?? 0.0,
      isSpecialContributor: json['is_special_contributor'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rif': rif,
      'business_name': businessName,
      'contact_name': contactName,
      'phone': phone,
      'email': email,
      'address': address,
      'credit_days': creditDays,
      'iva_retention_percent': ivaRetentionPercent,
      'islr_retention_percent': islrRetentionPercent,
      'is_special_contributor': isSpecialContributor,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
