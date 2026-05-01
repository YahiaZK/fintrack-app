import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_entry.dart';
import 'spending_habit_task_generator.dart';

class TransactionService {
  TransactionService(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _col =>
      _userDoc.collection('transactions');

  CollectionReference<Map<String, dynamic>> get _questsCol =>
      _userDoc.collection('quests');

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
    final now = DateTime.now();
    final currentEntry = TransactionEntry(
      id: newDoc.id,
      name: name,
      amount: amount,
      type: type,
      category: category,
      date: date,
    );
    final generatedTask = type == TransactionType.expense
        ? await _buildSpendingHabitTask(currentEntry, now)
        : null;
    final generatedTaskDoc = generatedTask == null
        ? null
        : _questsCol.doc(generatedTask.id);

    await _firestore.runTransaction((txn) async {
      final userSnap = await txn.get(_userDoc);
      final generatedTaskSnap = generatedTaskDoc == null
          ? null
          : await txn.get(generatedTaskDoc);
      final totals = _readTotals(userSnap.data());

      final isIncome = type == TransactionType.income;
      final newNetWorth = isIncome
          ? totals.netWorth + amount
          : totals.netWorth - amount;
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

      if (generatedTask != null && generatedTaskDoc != null) {
        if (_hasOpenHabitTask(generatedTaskSnap)) {
          txn.set(generatedTaskDoc, {
            'lastTriggeredAt': FieldValue.serverTimestamp(),
            'lastTransactionId': newDoc.id,
            'triggerCount': FieldValue.increment(1),
            'score': generatedTask.score,
            'reason': generatedTask.reason,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          txn.set(
            generatedTaskDoc,
            _taskData(generatedTask, newDoc.id, now),
            SetOptions(merge: true),
          );
        }
      }
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
      final newSpent = isIncome ? totals.spent : totals.spent - entry.amount;

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

  Future<GeneratedHabitTask?> _buildSpendingHabitTask(
    TransactionEntry transaction,
    DateTime now,
  ) async {
    final recentStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 30));
    final recentSnap = await _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(recentStart))
        .get();
    final recent = recentSnap.docs
        .map((doc) => TransactionEntry.fromMap(doc.id, doc.data()))
        .where((entry) => entry.type == TransactionType.expense)
        .toList();

    return SpendingHabitTaskGenerator(
      now: () => now,
    ).buildTask(transaction: transaction, recentTransactions: recent);
  }

  bool _hasOpenHabitTask(DocumentSnapshot<Map<String, dynamic>>? snap) {
    if (snap == null || !snap.exists) return false;
    final data = snap.data();
    if (data == null) return false;
    return (data['completed'] as bool?) != true;
  }

  Map<String, dynamic> _taskData(
    GeneratedHabitTask task,
    String transactionId,
    DateTime now,
  ) {
    return {
      'name': task.name,
      'xp': task.xp,
      'category': task.category,
      'frequency': 'habit',
      'completed': false,
      'completedAt': null,
      'order': 1000,
      'source': 'spending_habit',
      'habitKey': task.habitKey,
      'itemLabel': task.itemLabel,
      'durationDays': task.durationDays,
      'score': task.score,
      'quantity': task.quantity,
      'recentCount7': task.recentCount7,
      'recentCount30': task.recentCount30,
      'recentTotal14': task.recentTotal14,
      'reason': task.reason,
      'lastTransactionId': transactionId,
      'triggerCount': FieldValue.increment(1),
      'activeUntil': Timestamp.fromDate(
        now.add(Duration(days: task.durationDays)),
      ),
      'lastTriggeredAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
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
