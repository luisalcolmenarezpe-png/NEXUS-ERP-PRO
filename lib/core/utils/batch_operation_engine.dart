// lib/core/utils/batch_operation_engine.dart

class BatchPriceUpdateItem {
  final String productId;
  final double currentCostUsd;
  final double currentSalePriceUsd;

  BatchPriceUpdateItem({
    required this.productId,
    required this.currentCostUsd,
    required this.currentSalePriceUsd,
  });
}

class BatchOperationEngine {
  /// Aplica un incremento o decremento porcentual masivo a una lista de productos
  static List<Map<String, dynamic>> applyPercentagePriceAdjustment({
    required List<BatchPriceUpdateItem> items,
    required double percentageAdjustment, // Ej: +10.0 para subir 10%, -5.0 para descuento
  }) {
    final double factor = 1.0 + (percentageAdjustment / 100.0);

    return items.map((item) {
      final newPrice = item.currentSalePriceUsd * factor;
      return {
        'id': item.productId,
        'new_sale_price_usd': double.parse(newPrice.toStringAsFixed(4)),
      };
    }).toList();
  }

  /// Recalcula masivamente los precios de venta fijando un margen de ganancia objetivo sobre el costo
  static List<Map<String, dynamic>> applyTargetMarginAdjustment({
    required List<BatchPriceUpdateItem> items,
    required double targetMarginPercentage, // Ej: 30% (Límite SUNDDE)
  }) {
    if (targetMarginPercentage >= 100.0) throw ArgumentError('El margen no puede ser >= 100%');

    return items.map((item) {
      // Precio = Costo / (1 - Margen)
      final newPrice = item.currentCostUsd / (1.0 - (targetMarginPercentage / 100.0));
      return {
        'id': item.productId,
        'new_sale_price_usd': double.parse(newPrice.toStringAsFixed(4)),
      };
    }).toList();
  }
}
