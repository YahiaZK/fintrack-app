import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/goal.dart';

class GoalService {
  GoalService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('goals');

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
    required int currentAmount,
    DateTime? deadline,
  }) {
    return _col.add({
      'name': name,
      'category': category,
      'totalAmount': totalAmount,
      'currentAmount': currentAmount,
      if (deadline != null) 'deadline': Timestamp.fromDate(deadline),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addAmount({required String goalId, required int amount}) {
    return _col.doc(goalId).update({
      'currentAmount': FieldValue.increment(amount),
    });
  }

  Future<void> delete({required String goalId}) {
    return _col.doc(goalId).delete();
  }
}
