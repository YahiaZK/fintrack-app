import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../services/goal_service.dart';
import 'user_providers.dart';

final goalServiceProvider = Provider<GoalService>((ref) {
  return GoalService(ref.watch(firestoreProvider));
});

final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(goalServiceProvider).watch();
});
