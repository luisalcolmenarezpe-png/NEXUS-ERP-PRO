class CustomerModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxId;
  final String createdAt;
  final String syncStatus;
  final String lastModified;

  CustomerModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.taxId,
    required this.createdAt,
    this.syncStatus = 'pending_sync',
    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'tax_id': taxId,
      'created_at': createdAt,
      'sync_status': syncStatus,
      'last_modified': lastModified,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      taxId: map['tax_id'] as String?,
      createdAt: map['created_at'] as String,
      syncStatus: map['sync_status'] as String,
      lastModified: map['last_modified'] as String,
    );
  }
}
