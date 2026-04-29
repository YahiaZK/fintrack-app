import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quest.dart';

class QuestService {
  QuestService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('quests');

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
        return bd.compareTo(ad);
      });
      return quests;
    });
  }
}
