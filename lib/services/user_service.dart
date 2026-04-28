import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

const String kUserDocId = 'me';

class UserService {
  UserService(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('users').doc(kUserDocId);

  Future<void> save(UserProfile profile) {
    return _doc.set({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<UserProfile?> watch() {
    return _doc.snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return UserProfile.fromMap(data);
    });
  }

  Future<UserProfile?> read() async {
    final snap = await _doc.get();
    final data = snap.data();
    if (data == null) return null;
    return UserProfile.fromMap(data);
  }
}
