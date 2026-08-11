class ProductModel {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final double price;
  final double cost;
  final double stockQuantity;
  final String? category;
  final String? barcode;
  final String syncStatus;
  final String lastModified;

  ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    required this.price,
    required this.cost,
    this.stockQuantity = 0.0,
    this.category,
    this.barcode,
    this.syncStatus = 'pending_sync',
    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'price': price,
      'cost': cost,
      'stock_quantity': stockQuantity,
      'category': category,
      'barcode': barcode,
      'sync_status': syncStatus,
      'last_modified': lastModified,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      sku: map['sku'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      stockQuantity: (map['stock_quantity'] as num).toDouble(),
      category: map['category'] as String?,
      barcode: map['barcode'] as String?,
      syncStatus: map['sync_status'] as String,
      lastModified: map['last_modified'] as String,
    );
  }
}
