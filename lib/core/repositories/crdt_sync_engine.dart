// lib/core/repositories/crdt_sync_engine.dart

class CrdtRecord {
  final String id;
  final Map<String, dynamic> data;
  final int hlcTimestamp; // Hybrid Logical Clock timestamp
  final String nodeDeviceId; // Identificador único de la caja/terminal

  CrdtRecord({
    required this.id,
    required this.data,
    required this.hlcTimestamp,
    required this.nodeDeviceId,
  });
}

class CrdtSyncEngine {
  /// Resuelve conflictos entre registros locales y remotos usando LWW (Last-Write-Wins)
  static CrdtRecord resolveConflict(CrdtRecord local, CrdtRecord remote) {
    if (remote.hlcTimestamp > local.hlcTimestamp) {
      return remote;
    } else if (remote.hlcTimestamp < local.hlcTimestamp) {
      return local;
    } else {
      // Desempate por ID de nodo para garantízarse determinismo sin bloqueos
      return remote.nodeDeviceId.compareTo(local.nodeDeviceId) > 0 ? remote : local;
    }
  }
}
