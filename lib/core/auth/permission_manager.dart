// lib/core/auth/permission_manager.dart

enum UserPermission {
  processSale,         // Cobrar en POS
  changeProductPrice,  // Cambiar costo/precio de venta
  applyDiscount,       // Aplicar descuentos
  voidInvoice,         // Anular facturas emitidas
  viewReports,         // Ver reportes de ventas/ganancias
  manageInventory,     // Modificar o ajustar stock
  manageUsers,         // Crear/eliminar usuarios y roles
  pettyCashOutFlow,    // Registrar egresos de Caja Chica
}

enum UserRole { admin, owner, manager, cashier, inventoryTech }

class PermissionManager {
  static final Map<UserRole, List<UserPermission>> _rolePermissions = {
    UserRole.owner: UserPermission.values, // Acceso Total
    UserRole.admin: UserPermission.values,
    UserRole.manager: [
      UserPermission.processSale,
      UserPermission.applyDiscount,
      UserPermission.voidInvoice,
      UserPermission.viewReports,
      UserPermission.manageInventory,
      UserPermission.pettyCashOutFlow,
    ],
    UserRole.cashier: [
      UserPermission.processSale,
      UserPermission.pettyCashOutFlow,
    ],
    UserRole.inventoryTech: [
      UserPermission.manageInventory,
    ],
  };

  /// Verifica si el usuario actual posee el permiso necesario para realizar una acción
  static bool hasPermission(UserRole role, UserPermission permission) {
    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains(permission);
  }

  /// Permite autorizaciones dinámicas mediante clave/token de supervisor
  static bool authorizeSupervisorOverride({
    required String supervisorPin,
    required String validPin,
  }) {
    return supervisorPin == validPin;
  }
}
