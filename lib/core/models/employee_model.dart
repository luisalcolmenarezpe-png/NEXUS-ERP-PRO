class EmployeeModel {
  final String id;
  final String name;
  final String role;
  final String accessLevel;
  final String securityPin;
  final String createdAt;
  final String syncStatus;
  final String lastModified;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.accessLevel,
    required this.securityPin,
    required this.createdAt,
    this.syncStatus = 'pending_sync',
    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'access_level': accessLevel,
      'security_pin': securityPin,
      'created_at': createdAt,
      'sync_status': syncStatus,
      'last_modified': lastModified,
    };
  }

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      accessLevel: map['access_level'] as String,
      securityPin: map['security_pin'] as String,
      createdAt: map['created_at'] as String,
      syncStatus: map['sync_status'] as String,
      lastModified: map['last_modified'] as String,
    );
  }
}
