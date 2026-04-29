import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../services/user_service.dart';
import 'auth_providers.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userServiceProvider = Provider<UserService?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final uid = auth.value?.uid;
  if (uid == null) return null;
  return UserService(ref.watch(firestoreProvider), uid);
});

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final service = ref.watch(userServiceProvider);
  if (service == null) return Stream.value(null);
  return service.watch();
});
