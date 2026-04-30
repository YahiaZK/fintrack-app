import 'transaction_entry.dart';

class TransactionProposal {
  const TransactionProposal({
    required this.name,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  final String name;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;

  factory TransactionProposal.fromMap(Map<String, dynamic> data) {
    final raw = data['date'];
    final DateTime parsedDate;
    if (raw is String) {
      parsedDate = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }
    return TransactionProposal(
      name: (data['name'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: (data['type'] as String?) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: (data['category'] as String?) ?? '',
      date: parsedDate,
    );
  }
}
