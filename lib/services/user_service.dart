import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class UserService {
  UserService(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('users').doc(_uid);

  Future<void> save(UserProfile profile) {
    return _doc.set({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> createInitial({required String email}) {
    return _doc.set({
      'email': email,
      'onboardingCompleted': false,
      'xp': 100,
      'createdAt': FieldValue.serverTimestamp(),
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

  Future<void> resetXp() {
    return _doc.set({
      'xp': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markToolGuideSeen(String toolKey) {
    return _doc.set({
      'seenToolGuides': FieldValue.arrayUnion([toolKey]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserProfile?> read() async {
    final snap = await _doc.get();
    final data = snap.data();
    if (data == null) return null;
    return UserProfile.fromMap(data);
  }
}
