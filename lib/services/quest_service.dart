import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quest.dart';

class QuestService {
  QuestService(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(_uid).collection('quests');

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  Stream<List<Quest>> watch() {
    return _col.snapshots().map((snap) {
      final quests = snap.docs
          .map((d) => Quest.fromMap(d.id, d.data()))
          .toList();
      quests.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });
      return quests;
    });
  }

  Future<void> seedDefaultsIfEmpty() async {
    final existing = await _col.limit(1).get();
    if (existing.docs.isNotEmpty) return;
    final batch = _firestore.batch();
    for (final entry in _defaultQuests) {
      batch.set(_col.doc(entry.id), {
        'name': entry.name,
        'xp': entry.xp,
        'category': entry.category,
        'frequency': entry.frequency,
        'completed': false,
        'order': entry.order,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> completeQuest(Quest quest) {
    final batch = _firestore.batch();
    batch.set(_col.doc(quest.id), {
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(_userDoc, {
      'xp': FieldValue.increment(quest.xp),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return batch.commit();
  }
}

class _DefaultQuest {
  const _DefaultQuest({
    required this.id,
    required this.name,
    required this.xp,
    required this.category,
    required this.frequency,
    required this.order,
  });

  final String id;
  final String name;
  final int xp;
  final String category;
  final String frequency;
  final int order;
}

const List<_DefaultQuest> _defaultQuests = [
  _DefaultQuest(
    id: 'daily_log_expenses',
    name: "Log today's expenses",
    xp: 750,
    category: 'bills',
    frequency: 'daily',
    order: 1,
  ),
  _DefaultQuest(
    id: 'daily_stay_under_budget',
    name: 'Stay under your daily budget',
    xp: 800,
    category: 'food',
    frequency: 'daily',
    order: 2,
  ),
  _DefaultQuest(
    id: 'daily_save_toward_goal',
    name: 'Save toward your goal',
    xp: 650,
    category: 'savings',
    frequency: 'daily',
    order: 3,
  ),
  _DefaultQuest(
    id: 'weekly_budget_review',
    name: 'Complete a weekly budget review',
    xp: 1250,
    category: 'bills',
    frequency: 'weekly',
    order: 1,
  ),
  _DefaultQuest(
    id: 'weekly_save_income',
    name: 'Save 10% of this week\'s income',
    xp: 1400,
    category: 'savings',
    frequency: 'weekly',
    order: 2,
  ),
];
