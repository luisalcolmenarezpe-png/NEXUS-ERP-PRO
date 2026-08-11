/// core/database/db_helper.dart
/// Manejador de base de datos local ultra-segura con SQLCipher y Hash Chaining
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('erp_secure_storage.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Apertura de base de datos cifrada con SQLCipher (AES-256)
    return await openDatabase(
      path,
      password: 'TU_CLAVE_DE_CIFRADO_SEGURA', // En producción se gestiona mediante llavero seguro del dispositivo
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabla de Productos / Inventario Multi-Rubro
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        cost_price REAL NOT NULL,
        selling_price REAL NOT NULL,
        stock REAL NOT NULL,
        min_threshold REAL NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de Transacciones Offline con Hash Chaining (Seguridad anti-fraude)
    await db.execute('''
      CREATE TABLE pos_offline_transactions (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL, -- 'SALE', 'WASTE', 'INVENTORY_RECEIVE'
        total_amount REAL NOT NULL,
        payload TEXT NOT NULL,
        previous_hash TEXT NOT NULL,
        current_hash TEXT NOT NULL,
        synced INTEGER NOT NULL -- 0: Pendiente, 1: Sincronizado en la Nube
      )
    ''');
  }

  /// Inserta una transacción asegurando la integridad mediante Hash Chaining
  Future<void> insertSecureTransaction({
    required String id,
    required String type,
    required double totalAmount,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    
    // Obtener el hash de la última transacción registrada para mantener la cadena
    final lastTx = await db.rawQuery(
      'SELECT current_hash FROM pos_offline_transactions ORDER BY timestamp DESC LIMIT 1'
    );
    
    final previousHash = lastTx.isNotEmpty 
        ? lastTx.first['current_hash'] as String 
        : 'GENESIS_HASH_BLOCK';

    final timestamp = DateTime.now().toIso8601String();
    final payload = jsonEncode(data);

    // Generar hash actual combinando los datos y el hash anterior (Blockchain ligero local)
    final rawString = '$id$timestamp$type$totalAmount$payload$previousHash';
    final currentHash = sha256.convert(utf8.encode(rawString)).toString();

    await db.insert('pos_offline_transactions', {
      'id': id,
      'timestamp': timestamp,
      'type': type,
      'total_amount': totalAmount,
      'payload': payload,
      'previous_hash': previousHash,
      'current_hash': currentHash,
      'synced': 0,
    });
  }
}
