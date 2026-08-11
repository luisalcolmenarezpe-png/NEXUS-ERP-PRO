/// core/auth/role_guard_widget.dart
/// Componente de seguridad visual para restringir vistas según el rol del usuario
import 'package:flutter/material.dart';
import 'role_manager.dart';

class RoleGuardWidget extends StatelessWidget {
  const RoleGuardWidget({
    Key? key,
    required this.requiredRole,
    required this.child,
  }) : super(key: key);

  final UserRole requiredRole;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    bool hasAccess = false;

    switch (requiredRole) {
      case UserRole.admin:
        hasAccess = RoleManager.canAccessAdminDashboard();
        break;
      case UserRole.cashier:
        hasAccess = RoleManager.canAccessPos();
        break;
      case UserRole.fieldOperator:
        hasAccess = RoleManager.canAccessWasteEntry();
        break;
    }

    if (!hasAccess) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso Restringido')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_outline, size: 64, color: Colors.redAccent),
                SizedBox(height: 16),
                Text(
                  'Acceso No Autorizado',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Tu rol actual no tiene permisos para visualizar este módulo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
