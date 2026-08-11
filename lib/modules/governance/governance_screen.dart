import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

// ==========================================
// 1. STATE MANAGER (Gestor de Estado Gobernanza)
// ==========================================
class GovernanceState extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> _allLogs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get logs => _filteredLogs;
  bool get isLoading => _isLoading;

  GovernanceState() {
    loadLogs();
  }

  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      // En producción, esto debería tener paginación (LIMIT/OFFSET)
      _allLogs = await db.query('audit_logs', orderBy: 'timestamp DESC');
      _filteredLogs = List.from(_allLogs);
    } catch (e) {
      debugPrint('Error al cargar logs de auditoría: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtrado in-memory para demostración rápida (Podría hacerse por SQL)
  void applyFilters({String? userName, DateTime? selectedDate}) {
    _filteredLogs = _allLogs.where((log) {
      bool matchesUser = true;
      bool matchesDate = true;

      // Filtro de Usuario
      if (userName != null && userName.trim().isNotEmpty) {
        final logUser = (log['user_name'] ?? '').toString().toLowerCase();
        matchesUser = logUser.contains(userName.toLowerCase());
      }

      // Filtro de Fecha
      if (selectedDate != null) {
        final logDateStr = log['timestamp'] as String?;
        if (logDateStr != null) {
          final logDate = DateTime.tryParse(logDateStr);
          if (logDate != null) {
            matchesDate = logDate.year == selectedDate.year &&
                          logDate.month == selectedDate.month &&
                          logDate.day == selectedDate.day;
          }
        }
      }

      return matchesUser && matchesDate;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    _filteredLogs = List.from(_allLogs);
    notifyListeners();
  }
}

// ==========================================
// 2. UI: GOVERNANCE SCREEN (Módulo de Auditoría)
// ==========================================
class GovernanceScreen extends StatefulWidget {
  const GovernanceScreen({Key? key}) : super(key: key);

  @override
  State<GovernanceScreen> createState() => _GovernanceScreenState();
}

class _GovernanceScreenState extends State<GovernanceScreen> {
  final GovernanceState _state = GovernanceState();
  final TextEditingController _userSearchCtrl = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _state.dispose();
    _userSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _applyFilters();
    }
  }

  void _applyFilters() {
    _state.applyFilters(
      userName: _userSearchCtrl.text,
      selectedDate: _selectedDate,
    );
  }

  void _clearFilters() {
    setState(() {
      _userSearchCtrl.clear();
      _selectedDate = null;
    });
    _state.clearFilters();
  }

  IconData _getModuleIcon(String module) {
    switch (module.toUpperCase()) {
      case 'FINANZAS': return Icons.account_balance_wallet;
      case 'POS': return Icons.point_of_sale;
      case 'SCM': return Icons.inventory_2;
      case 'CRM': return Icons.people;
      case 'RRHH': return Icons.badge;
      case 'ACTIVOS': return Icons.precision_manufacturing;
      default: return Icons.security;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gobernanza: Auditoría Ghost (Inmutable)'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar Logs',
            onPressed: _state.loadLogs,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PANEL DE FILTROS (Quién y Cuándo)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _userSearchCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por Usuario / Empleado',
                          prefixIcon: Icon(Icons.person_search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Filtrar por Fecha',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          child: Text(
                            _selectedDate == null 
                                ? 'Todas las fechas' 
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: TextStyle(
                              color: _selectedDate == null ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Limpiar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // BITÁCORA (Lista Inmutable)
            Expanded(
              child: ListenableBuilder(
                listenable: _state,
                builder: (context, _) {
                  if (_state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_state.logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay registros de auditoría que coincidan con los filtros.', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: _state.logs.length,
                    itemBuilder: (context, index) {
                      final log = _state.logs[index];
                      final timestamp = DateTime.parse(log['timestamp'] as String).toLocal();
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: 1,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                            child: Icon(_getModuleIcon(log['module'] as String? ?? ''), color: Colors.redAccent),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                log['action'] ?? 'Acción Desconocida',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Usuario: ${log['user_name']} (ID: ${log['user_id']})', style: const TextStyle(color: Colors.blueAccent)),
                              const SizedBox(height: 2),
                              Text(log['details'] ?? 'Sin detalles adicionales.'),
                            ],
                          ),
                        ),
                      );
                    },
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
