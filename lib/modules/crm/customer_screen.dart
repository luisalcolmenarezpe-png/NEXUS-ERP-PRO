import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import 'dart:math';

// ==========================================
// 1. STATE MANAGER (Gestor de Estado CRM)
// ==========================================
class CustomerState extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get clients => _clients;
  bool get isLoading => _isLoading;

  CustomerState() {
    loadClients();
  }

  Future<void> loadClients() async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      _clients = await db.query('clients', orderBy: 'name ASC');
    } catch (e) {
      debugPrint('Error al cargar clientes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveClient(Map<String, dynamic> client) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toUtc().toIso8601String();
    
    final data = Map<String, dynamic>.from(client);
    data['sync_status'] = 'pending_sync';
    data['last_modified'] = now;

    // Verificar si el cliente ya existe
    final existing = await db.query('clients', where: 'id = ?', whereArgs: [data['id']]);

    if (existing.isNotEmpty) {
      await db.update('clients', data, where: 'id = ?', whereArgs: [data['id']]);
    } else {
      // Si es nuevo, asegurar que tenga fecha de creación
      data['created_at'] = data['created_at'] ?? now;
      await db.insert('clients', data);
    }
    
    await loadClients();
  }

  Future<void> deleteClient(String id) async {
    final db = await _dbHelper.database;
    await db.delete('clients', where: 'id = ?', whereArgs: [id]);
    await loadClients();
  }
}

// ==========================================
// 2. UI: CUSTOMER SCREEN (Módulo CRM)
// ==========================================
class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final CustomerState _state = CustomerState();
  String _searchQuery = '';

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _showCustomerDialog({Map<String, dynamic>? client}) {
    showDialog(
      context: context,
      builder: (context) => _CustomerFormDialog(
        initialData: client,
        onSave: (savedClient) {
          _state.saveClient(savedClient);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM: Directorio de Clientes'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _state.loadClients,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera: Buscador y Botón de Crear
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o documento...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                  icon: const Icon(Icons.person_add),
                  label: const Text('Nuevo Cliente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showCustomerDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tabla de datos
            Expanded(
              child: ListenableBuilder(
                listenable: _state,
                builder: (context, _) {
                  if (_state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filtrado local básico para la búsqueda
                  final filteredClients = _state.clients.where((c) {
                    final name = (c['name'] ?? '').toString().toLowerCase();
                    final taxId = (c['tax_id'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || taxId.contains(_searchQuery);
                  }).toList();

                  if (filteredClients.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron clientes.', style: TextStyle(fontSize: 16)),
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
                            DataColumn(label: Text('Doc. Identidad')),
                            DataColumn(label: Text('Nombre / Razón Social')),
                            DataColumn(label: Text('Teléfono')),
                            DataColumn(label: Text('Dirección')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: filteredClients.map((c) {
                            return DataRow(
                              cells: [
                                DataCell(Text(c['tax_id'] ?? '-')),
                                DataCell(Text(
                                  c['name'] ?? '', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                                )),
                                DataCell(Text(c['phone'] ?? '-')),
                                DataCell(Text(c['address'] ?? '-')),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                        tooltip: 'Editar',
                                        onPressed: () => _showCustomerDialog(client: c),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        tooltip: 'Eliminar',
                                        onPressed: () => _state.deleteClient(c['id']),
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
// 3. UI: CUSTOMER FORM DIALOG
// ==========================================
class _CustomerFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const _CustomerFormDialog({Key? key, this.initialData, required this.onSave}) : super(key: key);

  @override
  State<_CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<_CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _taxIdCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameCtrl = TextEditingController(text: data?['name'] ?? '');
    _taxIdCtrl = TextEditingController(text: data?['tax_id'] ?? '');
    _phoneCtrl = TextEditingController(text: data?['phone'] ?? '');
    _addressCtrl = TextEditingController(text: data?['address'] ?? '');
    _emailCtrl = TextEditingController(text: data?['email'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taxIdCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final client = {
        'id': widget.initialData?['id'] ?? 'CLI_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
        'name': _nameCtrl.text.trim(),
        'tax_id': _taxIdCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
      };
      
      // Preservar la fecha original si es una edición
      if (widget.initialData != null && widget.initialData!.containsKey('created_at')) {
        client['created_at'] = widget.initialData!['created_at'];
      }
      
      widget.onSave(client);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialData == null ? 'Registrar Cliente' : 'Editar Cliente',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _taxIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Documento / RIF / Cédula',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido para facturación' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre / Razón Social',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dirección Fiscal',
                  prefixIcon: Icon(Icons.location_on),
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
          label: const Text('Guardar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, 
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
