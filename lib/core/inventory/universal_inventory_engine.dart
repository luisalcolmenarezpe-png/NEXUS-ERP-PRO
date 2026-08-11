// lib/core/inventory/universal_inventory_engine.dart

enum BusinessVertical { retail, clothing, furniture, hardware, autoParts, technology, supermarket }

enum InventoryExitType { displaySample, workshopConsumption, defectiveWarranty, transportShrinkage, sale, internalTransfer }

class ProductVariantMatrix {
  final String? size;
  final String? color;
  final String? material;
  final String? dimensions;
  final Map<String, dynamic> customAttributes;

  ProductVariantMatrix({
    this.size,
    this.color,
    this.material,
    this.dimensions,
    this.customAttributes = const {},
  });
}

class SerialTracking {
  final String serialNumber;
  final String? imei;
  final DateTime purchaseDate;
  final DateTime warrantyExpiration;

  SerialTracking({
    required this.serialNumber,
    this.imei,
    required this.purchaseDate,
    required this.warrantyExpiration,
  });

  bool get isUnderWarranty => DateTime.now().isBefore(warrantyExpiration);
}

class InventoryExitRecord {
  final String productId;
  final InventoryExitType exitType;
  final int quantity;
  final String reason;
  final String? evidence;
  final DateTime timestamp;
  final String authorizedBy;

  InventoryExitRecord({
    required this.productId,
    required this.exitType,
    required this.quantity,
    required this.reason,
    this.evidence,
    required this.timestamp,
    required this.authorizedBy,
  });
}

class UniversalInventoryEngine {
  static List<String> getVariantMatrixForVertical(BusinessVertical vertical) {
    switch (vertical) {
      case BusinessVertical.clothing:
        return ['size', 'color', 'material'];
      case BusinessVertical.furniture:
        return ['color', 'material', 'dimensions'];
      case BusinessVertical.hardware:
        return ['dimensions', 'material'];
      default:
        return [];
    }
  }

  static bool validateSerialUniqueness(List<SerialTracking> existingSerials, String newSerial) {
    return !existingSerials.any((s) => s.serialNumber == newSerial);
  }

  static String classifyExit(InventoryExitType type) {
    switch (type) {
      case InventoryExitType.sale:
        return 'Impacto contable: Ingreso por ventas - Disminución de inventario';
      case InventoryExitType.transportShrinkage:
      case InventoryExitType.defectiveWarranty:
        return 'Impacto contable: Gasto por pérdida - Disminución de inventario';
      case InventoryExitType.internalTransfer:
        return 'Impacto contable: Movimiento neutral entre almacenes';
      default:
        return 'Impacto contable: Gasto operativo - Disminución de inventario';
    }
  }

  static String calculateReorderAlert(int currentStock, int minStock, int reorderPoint) {
    if (currentStock <= minStock) return 'CRÍTICA';
    if (currentStock <= reorderPoint) return 'ADVERTENCIA';
    return 'NORMAL';
  }
}
