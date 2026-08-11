/// core/repositories/sync_repository.dart
/// Administra la sincronización segura entre la base local cifrada y el servidor en la nube
import 'dart:convert';
import 'package:http/http.dart' as http; // O el cliente HTTP que prefieras utilizar
import '../database/db_helper.dart';

class SyncRepository {
  final DBHelper _dbHelper = DBHelper.instance;
  final String cloudEndpoint = 'https://api.tu-erp-cloud.com/v1/sync'; // Endpoint base en la nube

  /// Extrae las transacciones pendientes de sincronización y las envía a la nube
  Future<Map<String, dynamic>> syncPendingTransactions() async {
    try {
      final db = await _dbHelper.database;

      // 1. Buscar transacciones locales no sincronizadas (synced = 0)
      final pendingTxs = await db.query(
        'pos_offline_transactions',
        where: 'synced = ?',
        whereArgs: [0],
        orderBy: 'timestamp ASC',
      );

      if (pendingTxs.isEmpty) {
        return {'success': true, 'message': 'No hay transacciones pendientes por sincronizar.'};
      }

      // 2. Preparar el paquete de datos para enviar a la nube
      final payloadList = pendingTxs.map((tx) => {
        'id': tx['id'],
        'timestamp': tx['timestamp'],
        'type': tx['type'],
        'total_amount': tx['total_amount'],
        'payload': jsonDecode(tx['payload'] as String),
        'previous_hash': tx['previous_hash'],
        'current_hash': tx['current_hash'],
      }).toList();

      // 3. Enviar mediante petición HTTP POST segura
      final response = await http.post(
        Uri.parse(cloudEndpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'transactions': payloadList}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 4. Si el servidor acepta los datos, marcar localmente como sincronizadas (synced = 1)
        for (var tx in pendingTxs) {
          await db.update(
            'pos_offline_transactions',
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [tx['id']],
          );
        }
        return {'success': true, 'syncedCount': pendingTxs.length};
      } else {
        return {'success': false, 'message': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      // Si falla por falta de internet, la app sigue funcionando offline sin alterar nada
      return {'success': false, 'message': 'Modo offline activo. Error de red: $e'};
    }
  }
}
