// lib/core/inventory/inventory_location_engine.dart

class InventoryLocation {
  final String warehouse; // Depósito
  final String aisle;     // Pasillo
  final String shelf;     // Estante
  final String bin;       // Posición / Casilla

  InventoryLocation({
    required this.warehouse,
    required this.aisle,
    required this.shelf,
    required this.bin,
  });

  Map<String, String> toJson() => {
    'warehouse': warehouse,
    'aisle': aisle,
    'shelf': shelf,
    'bin': bin,
  };

  factory InventoryLocation.fromJson(Map<String, dynamic> json) {
    return InventoryLocation(
      warehouse: json['warehouse'] ?? 'General',
      aisle: json['aisle'] ?? 'N/A',
      shelf: json['shelf'] ?? 'N/A',
      bin: json['bin'] ?? 'N/A',
    );
  }

  /// Formato scannable para etiquetas o búsqueda en almacén
  String toCode() => '$warehouse-$aisle-$shelf-$bin'.toUpperCase();
}

class DynamicProductExtension {
  final Map<String, dynamic> customFields;

  DynamicProductExtension(this.customFields);

  /// Obtiene o asigna un atributo dinámico (ej: "codigo_oem", "compatibilidad", "color")
  dynamic getAttribute(String key) => customFields[key];

  void setAttribute(String key, dynamic value) {
    customFields[key] = value;
  }
}
