import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import 'accounting_models.dart';

class LedgerEngine {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Posts a double-entry transaction to the ledger.
  /// Throws an exception if the debits and credits do not balance.
  Future<void> postTransaction(TransactionRecord transaction) async {
    if (!transaction.isValidDoubleEntry) {
      throw Exception('Transaction does not balance. Total debits must equal total credits.');
    }

    final db = await _dbHelper.database;

    // Use a transaction to ensure all-or-nothing execution
    await db.transaction((txn) async {
      // 1. Insert the transaction header
      await txn.insert(
        'transactions',
        {
          'id': transaction.id,
          'date': transaction.date.toIso8601String(),
          'description': transaction.description,
          'reference': transaction.reference,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // 2. Insert all journal entries and update account balances
      for (var entry in transaction.entries) {
        await txn.insert(
          'journal_entries',
          entry.toMap(transaction.id),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );

        // 3. Update the running balance of the account
        // Assuming normal balances:
        // Assets/Expenses increase with Debits.
        // Liabilities/Equity/Revenue increase with Credits.
        // Here we apply a simple `debit - credit` to track the raw delta,
        // and presentation logic can handle normal balances based on AccountType.
        final delta = entry.debit - entry.credit;

        await txn.rawUpdate('''
          UPDATE accounts 
          SET balance = balance + ? 
          WHERE id = ?
        ''', [delta, entry.accountId]);
      }
    });
  }

  /// Retrieves an account's current balance
  Future<double> getAccountBalance(String accountId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'accounts',
      columns: ['balance'],
      where: 'id = ?',
      whereArgs: [accountId],
    );

    if (result.isNotEmpty) {
      return result.first['balance'] as double;
    }
    throw Exception('Account not found');
  }
}
