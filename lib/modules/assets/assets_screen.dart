import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import 'dart:math';

// ==========================================
// 1. STATE MANAGER (Gestor de Estado Activos)
// ==========================================
class AssetsState extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> _assets = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get assets => _assets;
  bool get isLoading => _isLoading;

  AssetsState() {
    loadAssets();
  }

  Future<void> loadAssets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      _assets = await db.query('assets', orderBy: 'name ASC');
    } catch (e) {
      debugPrint('Error al cargar activos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAsset(Map<String, dynamic> asset) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toUtc().toIso8601String();
    
    final data = Map<String, dynamic>.from(asset);
    data['sync_status'] = 'pending_sync';
    data['last_modified'] = now;

    final existing = await db.query('assets', where: 'id = ?', whereArgs: [data['id']]);

    if (existing.isNotEmpty) {
      await db.update('assets', data, where: 'id = ?', whereArgs: [data['id']]);
    } else {
      data['created_at'] = data['created_at'] ?? now;
      await db.insert('assets', data);
    }
    
    await loadAssets();
  }

  Future<void> deleteAsset(String id) async {
    final db = await _dbHelper.database;
    await db.delete('assets', where: 'id = ?', whereArgs: [id]);
    await loadAssets();
  }
}

// ==========================================
// 2. UI: ASSETS SCREEN (Módulo de Activos)
// ==========================================
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({Key? key}) : super(key: key);

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  final AssetsState _state = AssetsState();
  String _searchQuery = '';

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _showAssetDialog({Map<String, dynamic>? asset}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AssetFormDialog(
        initialData: asset,
        onSave: (savedAsset) {
          _state.saveAsset(savedAsset);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activos: Control de Equipos y Maquinaria'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _state.loadAssets,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera: Buscador y Botón Crear
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o especificación...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.precision_manufacturing),
                  label: const Text('Registrar Equipo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showAssetDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tabla Visual
            Expanded(
              child: ListenableBuilder(
                listenable: _state,
                builder: (context, _) {
                  if (_state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredAssets = _state.assets.where((a) {
                    final name = (a['name'] ?? '').toString().toLowerCase();
                    final specs = (a['specifications'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || specs.contains(_searchQuery);
                  }).toList();

                  if (filteredAssets.isEmpty) {
                    return const Center(
                      child: Text('No hay activos registrados en el inventario físico.'),
                    );
                  }

                  return Card(
                    elevation: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                          columns: const [
                            DataColumn(label: Text('Equipo / Máquina')),
                            DataColumn(label: Text('Estado Operativo')),
                            DataColumn(label: Text('Próx. Mantenimiento')),
                            DataColumn(label: Text('Especificaciones Técnicas')),
                            DataColumn(label: Text('Normativa Operativa')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: filteredAssets.map((a) {
                            final status = a['status'] ?? 'Operativo';
                            final isOperational = status == 'Operativo';
                            return DataRow(
                              cells: [
                                DataCell(Text(a['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isOperational ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: isOperational ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(a['maintenance_date'] ?? 'No programado')),
                                DataCell(
                                  SizedBox(
                                    width: 200, // Limitar ancho para descripción larga
                                    child: Text(
                                      a['specifications'] ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      a['technical_norms'] ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                        onPressed: () => _showAssetDialog(asset: a),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        onPressed: () => _state.deleteAsset(a['id']),
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
// 3. UI: ASSET FORM DIALOG
// ==========================================
class _AssetFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const _AssetFormDialog({Key? key, this.initialData, required this.onSave}) : super(key: key);

  @override
  State<_AssetFormDialog> createState() => _AssetFormDialogState();
}

class _AssetFormDialogState extends State<_AssetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _specsCtrl;
  late TextEditingController _maintenanceDateCtrl;
  late TextEditingController _normsCtrl;
  
  String _selectedStatus = 'Operativo';
  final List<String> _statuses = ['Operativo', 'En Mantenimiento', 'Fuera de Servicio', 'Dañado'];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameCtrl = TextEditingController(text: data?['name'] ?? '');
    _specsCtrl = TextEditingController(text: data?['specifications'] ?? '');
    _maintenanceDateCtrl = TextEditingController(text: data?['maintenance_date'] ?? '');
    _normsCtrl = TextEditingController(text: data?['technical_norms'] ?? '');
    
    if (data != null && _statuses.contains(data['status'])) {
      _selectedStatus = data['status'];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specsCtrl.dispose();
    _maintenanceDateCtrl.dispose();
    _normsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final asset = {
        'id': widget.initialData?['id'] ?? 'AST_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100)}',
        'name': _nameCtrl.text.trim(),
        'specifications': _specsCtrl.text.trim(),
        'maintenance_date': _maintenanceDateCtrl.text.trim(),
        'technical_norms': _normsCtrl.text.trim(),
        'status': _selectedStatus,
      };
      
      if (widget.initialData != null && widget.initialData!.containsKey('created_at')) {
        asset['created_at'] = widget.initialData!['created_at'];
      }
      
      widget.onSave(asset);
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _maintenanceDateCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Registrar Equipo' : 'Actualizar Ficha Técnica'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre / Identificador', prefixIcon: Icon(Icons.precision_manufacturing)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado Actual',
                  prefixIcon: Icon(Icons.thermostat),
                  border: OutlineInputBorder(),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _maintenanceDateCtrl,
                decoration: InputDecoration(
                  labelText: 'Próximo Mantenimiento (Preventivo)',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: _selectDate,
                  )
                ),
                readOnly: true, // Forzar uso del DatePicker
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Especificaciones Técnicas (Modelo, Serie, Capacidad...)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _normsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Normativa Técnica / Protocolos de Seguridad',
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
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
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save),
          label: const Text('Guardar Ficha'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
        ),
      ],
    );
  }
}
