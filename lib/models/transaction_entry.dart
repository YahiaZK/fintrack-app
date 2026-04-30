import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.createdAt,
  });

  final String id;
  final String name;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final DateTime? createdAt;

  factory TransactionEntry.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    final dateTs = data['date'];
    return TransactionEntry(
      id: id,
      name: (data['name'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: (data['type'] as String?) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: (data['category'] as String?) ?? '',
      date: dateTs is Timestamp ? dateTs.toDate() : DateTime.now(),
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
