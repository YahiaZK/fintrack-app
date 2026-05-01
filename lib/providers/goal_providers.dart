import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../services/goal_service.dart';
import 'auth_providers.dart';
import 'user_providers.dart';

final goalServiceProvider = Provider<GoalService?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final uid = auth.value?.uid;
  if (uid == null) return null;
  return GoalService(ref.watch(firestoreProvider), uid);
});

final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  final service = ref.watch(goalServiceProvider);
  if (service == null) return Stream.value(const <Goal>[]);
  return service.watch();
});
