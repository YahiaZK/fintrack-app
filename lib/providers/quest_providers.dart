import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quest.dart';
import '../services/quest_service.dart';
import 'auth_providers.dart';
import 'user_providers.dart';

final questServiceProvider = Provider<QuestService?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final uid = auth.value?.uid;
  if (uid == null) return null;
  return QuestService(ref.watch(firestoreProvider), uid);
});

final questsStreamProvider = StreamProvider<List<Quest>>((ref) {
  final service = ref.watch(questServiceProvider);
  if (service == null) return Stream.value(const <Quest>[]);
  return service.watch();
});
