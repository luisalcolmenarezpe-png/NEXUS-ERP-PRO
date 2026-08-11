// lib/data/models/product_model.dart

class ProductModel {
  final String id;
  final String sku;
  final String barcode;
  final String name;
  final String description;
  final String category;
  final double weightedAverageCostUsd;
  final double landedCostUsd;
  final double retailPriceUsd;
  final double wholesalePriceUsd;
  final double sunddeMarginPercent;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final int reorderPoint;
  final Map<String, dynamic> customFields;
  final Map<String, String> locationHierarchy;
  final Map<String, dynamic>? variantMatrix;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.name,
    required this.description,
    required this.category,
    required this.weightedAverageCostUsd,
    required this.landedCostUsd,
    required this.retailPriceUsd,
    required this.wholesalePriceUsd,
    required this.sunddeMarginPercent,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.reorderPoint,
    this.customFields = const {},
    this.locationHierarchy = const {},
    this.variantMatrix,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  double get actualMarginPercent => 
      ((retailPriceUsd - landedCostUsd) / landedCostUsd) * 100;
      
  bool get isReorderNeeded => currentStock <= reorderPoint;
  
  bool get isSunddeCompliant => actualMarginPercent <= sunddeMarginPercent;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      sku: json['sku'],
      barcode: json['barcode'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      weightedAverageCostUsd: json['weighted_average_cost_usd']?.toDouble() ?? 0.0,
      landedCostUsd: json['landed_cost_usd']?.toDouble() ?? 0.0,
      retailPriceUsd: json['retail_price_usd']?.toDouble() ?? 0.0,
      wholesalePriceUsd: json['wholesale_price_usd']?.toDouble() ?? 0.0,
      sunddeMarginPercent: json['sundde_margin_percent']?.toDouble() ?? 30.0,
      currentStock: json['current_stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      maxStock: json['max_stock'] ?? 0,
      reorderPoint: json['reorder_point'] ?? 0,
      customFields: json['custom_fields'] ?? {},
      locationHierarchy: Map<String, String>.from(json['location_hierarchy'] ?? {}),
      variantMatrix: json['variant_matrix'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'barcode': barcode,
      'name': name,
      'description': description,
      'category': category,
      'weighted_average_cost_usd': weightedAverageCostUsd,
      'landed_cost_usd': landedCostUsd,
      'retail_price_usd': retailPriceUsd,
      'wholesale_price_usd': wholesalePriceUsd,
      'sundde_margin_percent': sunddeMarginPercent,
      'current_stock': currentStock,
      'min_stock': minStock,
      'max_stock': maxStock,
      'reorder_point': reorderPoint,
      'custom_fields': customFields,
      'location_hierarchy': locationHierarchy,
      'variant_matrix': variantMatrix,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
