import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'erp_pos_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Basic accounting tables for double-entry (Offline-First)
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL DEFAULT 0.0,
        currency TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending_sync',
        last_modified TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        reference TEXT,
        sync_status TEXT DEFAULT 'pending_sync',
        last_modified TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        transaction_id TEXT NOT NULL,
        account_id TEXT NOT NULL,
        debit REAL DEFAULT 0.0,
        credit REAL DEFAULT 0.0,
        sync_status TEXT DEFAULT 'pending_sync',
        last_modified TEXT NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id),
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // Products table for SCM/POS (Offline-First)
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        sku TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        cost REAL NOT NULL,
        stock_quantity REAL DEFAULT 0.0,
        category TEXT,
        barcode TEXT,
        sync_status TEXT DEFAULT 'pending_sync',
        last_modified TEXT NOT NULL
      )
    ''');

    // Clients table for CRM/POS (Offline-First)
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        tax_id TEXT,
        created_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending_sync',
        last_modified TEXT NOT NULL
      )
    ''');

    // Offline POS transactions table (Header)
    await db.execute('''
      CREATE TABLE pos_offline_transactions (
        id TEXT PRIMARY KEY,
        client_id TEXT,
        total_amount REAL NOT NULL,
        tax_amount REAL DEFAULT 0.0,
        discount_amount REAL DEFAULT 0.0,
        status TEXT NOT NULL, -- e.g., 'completed', 'voided'
        sync_status TEXT DEFAULT 'pending_sync',
        created_at TEXT NOT NULL,
        synced_at TEXT,
        FOREIGN KEY (client_id) REFERENCES clients (id)
      )
    ''');

    // Offline POS transaction lines (Details)
    await db.execute('''
      CREATE TABLE pos_offline_transaction_lines (
        id TEXT PRIMARY KEY,
        transaction_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES pos_offline_transactions (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }
}
