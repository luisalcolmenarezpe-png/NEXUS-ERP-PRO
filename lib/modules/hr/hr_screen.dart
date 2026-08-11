import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/database/db_helper.dart';
import 'dart:math';

// ==========================================
// 1. STATE MANAGER (Gestor de Estado RRHH)
// ==========================================
class HRState extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get employees => _employees;
  bool get isLoading => _isLoading;

  HRState() {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      _employees = await db.query('employees', orderBy: 'name ASC');
    } catch (e) {
      debugPrint('Error al cargar empleados: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveEmployee(Map<String, dynamic> employee) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toUtc().toIso8601String();
    
    final data = Map<String, dynamic>.from(employee);
    data['sync_status'] = 'pending_sync';
    data['last_modified'] = now;

    final existing = await db.query('employees', where: 'id = ?', whereArgs: [data['id']]);

    if (existing.isNotEmpty) {
      await db.update('employees', data, where: 'id = ?', whereArgs: [data['id']]);
    } else {
      data['created_at'] = data['created_at'] ?? now;
      await db.insert('employees', data);
    }
    
    await loadEmployees();
  }

  Future<void> deleteEmployee(String id) async {
    final db = await _dbHelper.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
    await loadEmployees();
  }
}

// ==========================================
// 2. UI: HR SCREEN (Módulo de Recursos Humanos)
// ==========================================
class HRScreen extends StatefulWidget {
  const HRScreen({Key? key}) : super(key: key);

  @override
  State<HRScreen> createState() => _HRScreenState();
}

class _HRScreenState extends State<HRScreen> {
  final HRState _state = HRState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _showEmployeeDialog({Map<String, dynamic>? employee}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EmployeeFormDialog(
        initialData: employee,
        onSave: (savedEmployee) {
          _state.saveEmployee(savedEmployee);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RRHH: Gestión de Personal y Accesos'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _state.loadEmployees,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nómina de Usuarios del Sistema',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Registrar Empleado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => _showEmployeeDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tabla
            Expanded(
              child: ListenableBuilder(
                listenable: _state,
                builder: (context, _) {
                  if (_state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_state.employees.isEmpty) {
                    return const Center(
                      child: Text('No hay empleados registrados. Añade uno para comenzar.'),
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
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Cargo / Rol')),
                            DataColumn(label: Text('Nivel de Acceso')),
                            DataColumn(label: Text('PIN (Ofuscado)')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: _state.employees.map((e) {
                            return DataRow(
                              cells: [
                                DataCell(Text(e['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(e['role'] ?? '')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: e['access_level'] == 'Administrador' ? Colors.redAccent.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      e['access_level'] ?? '',
                                      style: TextStyle(
                                        color: e['access_level'] == 'Administrador' ? Colors.redAccent : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const DataCell(Text('****', style: TextStyle(letterSpacing: 2))), // Nunca mostramos el PIN real en la tabla
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                        onPressed: () => _showEmployeeDialog(employee: e),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        onPressed: () => _state.deleteEmployee(e['id']),
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
// 3. UI: EMPLOYEE FORM DIALOG
// ==========================================
class _EmployeeFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const _EmployeeFormDialog({Key? key, this.initialData, required this.onSave}) : super(key: key);

  @override
  State<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _pinCtrl;
  
  String _selectedAccess = 'Cajero';
  final List<String> _accessLevels = ['Cajero', 'Vendedor', 'Gerente', 'Administrador'];
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameCtrl = TextEditingController(text: data?['name'] ?? '');
    _roleCtrl = TextEditingController(text: data?['role'] ?? '');
    _pinCtrl = TextEditingController(text: data?['security_pin'] ?? '');
    if (data != null && _accessLevels.contains(data['access_level'])) {
      _selectedAccess = data['access_level'];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final employee = {
        'id': widget.initialData?['id'] ?? 'EMP_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100)}',
        'name': _nameCtrl.text.trim(),
        'role': _roleCtrl.text.trim(),
        'access_level': _selectedAccess,
        'security_pin': _pinCtrl.text.trim(),
      };
      
      if (widget.initialData != null && widget.initialData!.containsKey('created_at')) {
        employee['created_at'] = widget.initialData!['created_at'];
      }
      
      widget.onSave(employee);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Nuevo Empleado' : 'Editar Empleado'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre Completo', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roleCtrl,
                decoration: const InputDecoration(labelText: 'Cargo (ej. Analista)', prefixIcon: Icon(Icons.work)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAccess,
                decoration: const InputDecoration(
                  labelText: 'Nivel de Acceso (Permisos)',
                  prefixIcon: Icon(Icons.security),
                  border: OutlineInputBorder(),
                ),
                items: _accessLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAccess = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinCtrl,
                obscureText: _obscurePin,
                maxLength: 4,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'PIN de Seguridad (4 dígitos)',
                  prefixIcon: const Icon(Icons.dialpad),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'El PIN es requerido';
                  if (v.length != 4) return 'Debe tener exactamente 4 dígitos';
                  return null;
                },
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
