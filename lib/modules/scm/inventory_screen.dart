import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import 'dart:math';

// ==========================================
// 1. STATE MANAGER (Gestor de Estado)
// ==========================================
class InventoryState extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;

  InventoryState() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      _products = await db.query('products', orderBy: 'name ASC');
    } catch (e) {
      debugPrint('Error al cargar productos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProduct(Map<String, dynamic> product) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toUtc().toIso8601String();
    
    final data = Map<String, dynamic>.from(product);
    data['sync_status'] = 'pending_sync';
    data['last_modified'] = now;

    final existing = await db.query('products', where: 'id = ?', whereArgs: [data['id']]);

    if (existing.isNotEmpty) {
      await db.update('products', data, where: 'id = ?', whereArgs: [data['id']]);
    } else {
      await db.insert('products', data);
    }
    
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    final db = await _dbHelper.database;
    // Eliminación lógica o física (física en este caso simple)
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    await loadProducts();
  }
}

// ==========================================
// 2. UI: INVENTORY SCREEN
// ==========================================
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryState _state = InventoryState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _showProductDialog({Map<String, dynamic>? product}) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(
        initialData: product,
        onSave: (savedProduct) {
          _state.saveProduct(savedProduct);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCM: Inventario Inteligente'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _state.loadProducts,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera y botón de crear
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Catálogo de Productos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Artículo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: () => _showProductDialog(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tabla de datos
            Expanded(
              child: ListenableBuilder(
                listenable: _state,
                builder: (context, _) {
                  if (_state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_state.products.isEmpty) {
                    return const Center(
                      child: Text('No hay productos registrados en SQLite.'),
                    );
                  }

                  return Card(
                    elevation: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Código (SKU)')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Precio (USD)')),
                            DataColumn(label: Text('Costo (USD)')),
                            DataColumn(label: Text('Stock')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: _state.products.map((p) {
                            return DataRow(
                              cells: [
                                DataCell(Text(p['sku'] ?? '')),
                                DataCell(Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text('\$${(p['price'] as num).toStringAsFixed(2)}')),
                                DataCell(Text('\$${(p['cost'] as num).toStringAsFixed(2)}')),
                                DataCell(
                                  Text(
                                    '${p['stock_quantity']}',
                                    style: TextStyle(
                                      color: (p['stock_quantity'] as num) <= 0 ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange),
                                        onPressed: () => _showProductDialog(product: p),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _state.deleteProduct(p['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. UI: PRODUCT FORM DIALOG
// ==========================================
class _ProductFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const _ProductFormDialog({Key? key, this.initialData, required this.onSave}) : super(key: key);

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _skuCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _stockCtrl;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _skuCtrl = TextEditingController(text: data?['sku'] ?? '');
    _nameCtrl = TextEditingController(text: data?['name'] ?? '');
    _priceCtrl = TextEditingController(text: data != null ? data['price'].toString() : '');
    _costCtrl = TextEditingController(text: data != null ? data['cost'].toString() : '');
    _stockCtrl = TextEditingController(text: data != null ? data['stock_quantity'].toString() : '');
  }

  @override
  void dispose() {
    _skuCtrl.dispose();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _costCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final product = {
        'id': widget.initialData?['id'] ?? 'PROD_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
        'sku': _skuCtrl.text,
        'name': _nameCtrl.text,
        'description': '', // Campo opcional omitido por simplicidad
        'price': double.tryParse(_priceCtrl.text) ?? 0.0,
        'cost': double.tryParse(_costCtrl.text) ?? 0.0,
        'stock_quantity': double.tryParse(_stockCtrl.text) ?? 0.0,
        'category': 'General',
        'barcode': _skuCtrl.text, // Puede ser igual al sku para tests
      };
      widget.onSave(product);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Nuevo Producto' : 'Editar Producto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _skuCtrl,
                decoration: const InputDecoration(labelText: 'SKU / Código'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Artículo'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: 'Precio Venta (\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _costCtrl,
                      decoration: const InputDecoration(labelText: 'Costo (\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _stockCtrl,
                decoration: const InputDecoration(labelText: 'Stock Inicial'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: const Text('Guardar en BD'),
        ),
      ],
    );
  }
}
