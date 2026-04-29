import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quest.dart';
import '../services/quest_service.dart';
import 'user_providers.dart';

final questServiceProvider = Provider<QuestService>((ref) {
  return QuestService(ref.watch(firestoreProvider));
});

final questsStreamProvider = StreamProvider<List<Quest>>((ref) {
  return ref.watch(questServiceProvider).watch();
});
