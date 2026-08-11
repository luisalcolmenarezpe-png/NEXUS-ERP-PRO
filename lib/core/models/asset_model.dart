class AssetModel {
  final String id;
  final String name;
  final String? specifications;
  final String? maintenanceDate;
  final String? technicalNorms;
  final String status;
  final String createdAt;
  final String syncStatus;
  final String lastModified;

  AssetModel({
    required this.id,
    required this.name,
    this.specifications,
    this.maintenanceDate,
    this.technicalNorms,
    this.status = 'Operativo',
    required this.createdAt,
    this.syncStatus = 'pending_sync',
    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specifications': specifications,
      'maintenance_date': maintenanceDate,
      'technical_norms': technicalNorms,
      'status': status,
      'created_at': createdAt,
      'sync_status': syncStatus,
      'last_modified': lastModified,
    };
  }

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      specifications: map['specifications'] as String?,
      maintenanceDate: map['maintenance_date'] as String?,
      technicalNorms: map['technical_norms'] as String?,
      status: map['status'] as String,
      createdAt: map['created_at'] as String,
      syncStatus: map['sync_status'] as String,
      lastModified: map['last_modified'] as String,
    );
  }
}
