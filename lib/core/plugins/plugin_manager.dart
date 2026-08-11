// lib/core/plugins/plugin_manager.dart

abstract class ExternalAppPlugin {
  String get pluginId;
  String get pluginName;
  Future<bool> initialize();
  Future<Map<String, dynamic>> executeAction(String event, Map<String, dynamic> payload);
}

class PluginManager {
  // Toggles de Módulos (Activar/Desactivar según la necesidad del cliente)
  static Map<String, bool> activeModules = {
    'crm': true,
    'inventory': true,
    'vehicles_mechanic': false, // Desactivado si el cliente es una bodega
    'assets': true,
    'credit_financing': true,    // Módulo de créditos/fiao
  };

  static final Map<String, ExternalAppPlugin> _registeredPlugins = {};

  /// Registra e integra una aplicación o plugin externo
  static void registerPlugin(ExternalAppPlugin plugin) {
    _registeredPlugins[plugin.pluginId] = plugin;
    plugin.initialize();
  }

  /// Ejecuta un evento en un plugin conectado (ej. Enviar venta a app de crédito externa)
  static Future<Map<String, dynamic>?> triggerPluginEvent({
    required String pluginId,
    required String event,
    required Map<String, dynamic> data,
  }) async {
    final plugin = _registeredPlugins[pluginId];
    if (plugin == null) return null;
    return await plugin.executeAction(event, data);
  }

  /// Activa o desactiva un módulo dinámicamente según la suscripción de la empresa
  static void toggleModule(String moduleKey, bool isEnabled) {
    activeModules[moduleKey] = isEnabled;
  }
}
