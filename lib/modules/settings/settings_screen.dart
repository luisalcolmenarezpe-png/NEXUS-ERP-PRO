import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

// ==========================================
// 1. STATE MANAGER (Gestor de Estado Configuraciones)
// ==========================================
class SettingsState extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  
  double _exchangeRateVES = 0.0;
  bool _isLoading = false;

  double get exchangeRateVES => _exchangeRateVES;
  bool get isLoading => _isLoading;

  SettingsState() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: ['exchange_rate_ves'],
      );

      if (result.isNotEmpty) {
        final valueStr = result.first['value'] as String;
        _exchangeRateVES = double.tryParse(valueStr) ?? 0.0;
      }
    } catch (e) {
      debugPrint('Error al cargar configuraciones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExchangeRate(double newRate) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toUtc().toIso8601String();

    await db.update(
      'settings',
      {
        'value': newRate.toString(),
        'last_modified': now,
        'sync_status': 'pending_sync'
      },
      where: 'key = ?',
      whereArgs: ['exchange_rate_ves'],
    );
    
    // Registrar el cambio en la bitácora de auditoría
    await db.insert('audit_logs', {
      'id': 'LOG_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': 'SYS_ADMIN', // Esto debería venir de la sesión actual
      'user_name': 'Administrador',
      'module': 'CONFIGURACIÓN',
      'action': 'ACTUALIZAR TASA',
      'details': 'Tasa de cambio VES actualizada a $newRate',
      'timestamp': now,
      'sync_status': 'pending_sync',
    });

    await loadSettings();
  }
}

// ==========================================
// 2. UI: SETTINGS SCREEN (Panel Administrativo)
// ==========================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsState _state = SettingsState();
  final TextEditingController _rateCtrl = TextEditingController();

  @override
  void dispose() {
    _state.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _showUpdateDialog(double currentRate) {
    _rateCtrl.text = currentRate.toStringAsFixed(2);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actualizar Tasa de Cambio (BCV / Mercado)'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: _rateCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Nueva Tasa (VES por USD)',
                prefixIcon: Icon(Icons.currency_exchange),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingrese un valor';
                final val = double.tryParse(v);
                if (val == null || val <= 0) return 'Ingrese una tasa válida mayor a 0';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newRate = double.parse(_rateCtrl.text);
                  _state.updateExchangeRate(newRate);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tasa actualizada correctamente en toda la red offline.'),
                      backgroundColor: Colors.green,
                    )
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Aplicar Tasa'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones Globales'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          if (_state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parámetros Financieros (Multimoneda)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.attach_money, color: Colors.white, size: 30),
                    ),
                    title: const Text('Tasa de Cambio Base (USD -> VES)', style: TextStyle(fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          '1.00 USD  =  ${_state.exchangeRateVES.toStringAsFixed(2)} VES',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                        ),
                        const SizedBox(height: 8),
                        const Text('Esta tasa es utilizada por el motor contable y todos los Puntos de Venta (POS) para calcular pagos mixtos y asentar débitos/créditos equivalentes.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _showUpdateDialog(_state.exchangeRateVES),
                      icon: const Icon(Icons.edit),
                      label: const Text('Modificar'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
