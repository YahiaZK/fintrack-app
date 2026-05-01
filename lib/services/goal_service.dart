import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/goal.dart';

class InsufficientNetWorthException implements Exception {
  const InsufficientNetWorthException(this.available, this.requested);

  final double available;
  final int requested;

  @override
  String toString() =>
      'Insufficient net worth: have \$${available.toStringAsFixed(0)}, need \$$requested';
}

class GoalService {
  GoalService(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _col =>
      _userDoc.collection('goals');

  Stream<List<Goal>> watch() {
    return _col.snapshots().map((snap) {
      final goals = snap.docs
          .map((d) => Goal.fromMap(d.id, d.data()))
          .toList();
      goals.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return goals;
    });
  }

  Future<void> create({
    required String name,
    required String category,
    required int totalAmount,
    DateTime? deadline,
  }) {
    return _col.add({
      'name': name,
      'category': category,
      'totalAmount': totalAmount,
      'currentAmount': 0,
      if (deadline != null) 'deadline': Timestamp.fromDate(deadline),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addAmount({required String goalId, required int amount}) async {
    if (amount <= 0) return;
    await _firestore.runTransaction((tx) async {
      final goalRef = _col.doc(goalId);
      final userSnap = await tx.get(_userDoc);
      final available =
          (userSnap.data()?['totalNetWorth'] as num?)?.toDouble() ?? 0;
      if (available < amount) {
        throw InsufficientNetWorthException(available, amount);
      }
      tx.update(goalRef, {'currentAmount': FieldValue.increment(amount)});
      tx.set(_userDoc, {
        'totalNetWorth': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> delete({required String goalId}) async {
    await _firestore.runTransaction((tx) async {
      final goalRef = _col.doc(goalId);
      final goalSnap = await tx.get(goalRef);
      if (!goalSnap.exists) return;
      final saved = (goalSnap.data()?['currentAmount'] as num?)?.toInt() ?? 0;
      if (saved > 0) {
        tx.set(_userDoc, {
          'totalNetWorth': FieldValue.increment(saved),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      tx.delete(goalRef);
    });
  }
}
