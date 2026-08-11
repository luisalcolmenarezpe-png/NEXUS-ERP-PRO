enum AccountType { asset, liability, equity, revenue, expense }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;

  Account({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.currency = 'USD',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
      'currency': currency,
    };
  }
}

class JournalEntry {
  final String id;
  final String accountId;
  final double debit;
  final double credit;

  JournalEntry({
    required this.id,
    required this.accountId,
    this.debit = 0.0,
    this.credit = 0.0,
  }) : assert(debit >= 0 && credit >= 0, 'Amounts must be non-negative');

  Map<String, dynamic> toMap(String transactionId) {
    return {
      'id': id,
      'transaction_id': transactionId,
      'account_id': accountId,
      'debit': debit,
      'credit': credit,
    };
  }
}

class TransactionRecord {
  final String id;
  final DateTime date;
  final String description;
  final String? reference;
  final List<JournalEntry> entries;

  TransactionRecord({
    required this.id,
    required this.date,
    required this.description,
    this.reference,
    required this.entries,
  });

  /// Validates that total debits equal total credits.
  bool get isValidDoubleEntry {
    double totalDebits = entries.fold(0, (sum, entry) => sum + entry.debit);
    double totalCredits = entries.fold(0, (sum, entry) => sum + entry.credit);
    
    // Using a small epsilon for safe floating point comparison
    return (totalDebits - totalCredits).abs() < 0.0001;
  }
}
