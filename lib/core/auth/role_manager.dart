/// core/auth/role_manager.dart
/// Administra los roles y permisos de acceso para la aplicación multi-plataforma
enum UserRole { admin, cashier, fieldOperator }

class RoleManager {
  // Rol activo actual en el dispositivo (en producción se vincula con la sesión segura)
  static UserRole currentRole = UserRole.fieldOperator;

  static void setRole(UserRole role) {
    currentRole = role;
  }

  static bool canAccessAdminDashboard() {
    return currentRole == UserRole.admin;
  }

  static bool canAccessPos() {
    return currentRole == UserRole.admin || currentRole == UserRole.cashier;
  }

  static bool canAccessWasteEntry() {
    return true; // Todos los roles, incluidos operarios, pueden registrar mermas
  }
}
