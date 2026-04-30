import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_entry.dart';

class TransactionService {
  TransactionService(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _col =>
      _userDoc.collection('transactions');

  Stream<List<TransactionEntry>> watch() {
    return _col.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => TransactionEntry.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return b.date.compareTo(a.date);
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  Future<String> create({
    required String name,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
  }) async {
    final newDoc = _col.doc();
    await _firestore.runTransaction((txn) async {
      final userSnap = await txn.get(_userDoc);
      final totals = _readTotals(userSnap.data());

      final isIncome = type == TransactionType.income;
      final newNetWorth =
          isIncome ? totals.netWorth + amount : totals.netWorth - amount;
      final newSpent = isIncome ? totals.spent : totals.spent + amount;

      txn.set(newDoc, {
        'name': name,
        'amount': amount,
        'type': isIncome ? 'income' : 'expense',
        'category': category,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });
      txn.set(_userDoc, {
        'totalNetWorth': newNetWorth,
        'totalSpent': newSpent,
        'totalSaved': totals.saved,
      }, SetOptions(merge: true));
    });
    return newDoc.id;
  }

  Future<void> delete(TransactionEntry entry) {
    return _firestore.runTransaction((txn) async {
      final userSnap = await txn.get(_userDoc);
      final totals = _readTotals(userSnap.data());

      final isIncome = entry.type == TransactionType.income;
      final newNetWorth = isIncome
          ? totals.netWorth - entry.amount
          : totals.netWorth + entry.amount;
      final newSpent =
          isIncome ? totals.spent : totals.spent - entry.amount;

      txn.delete(_col.doc(entry.id));
      txn.set(_userDoc, {
        'totalNetWorth': newNetWorth,
        'totalSpent': newSpent,
        'totalSaved': totals.saved,
      }, SetOptions(merge: true));
    });
  }

  _Totals _readTotals(Map<String, dynamic>? data) {
    final d = data ?? const <String, dynamic>{};
    final monthlyIncome = (d['monthlyIncome'] as num?)?.toDouble() ?? 0;
    final monthlyExpenses = (d['monthlyExpenses'] as num?)?.toDouble() ?? 0;
    return _Totals(
      netWorth: (d['totalNetWorth'] as num?)?.toDouble() ?? monthlyIncome,
      spent: (d['totalSpent'] as num?)?.toDouble() ?? monthlyExpenses,
      saved: (d['totalSaved'] as num?)?.toDouble() ?? 0,
    );
  }
}

class _Totals {
  const _Totals({
    required this.netWorth,
    required this.spent,
    required this.saved,
  });

  final double netWorth;
  final double spent;
  final double saved;
}
