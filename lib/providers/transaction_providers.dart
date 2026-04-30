import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_entry.dart';
import '../services/transaction_service.dart';
import 'auth_providers.dart';
import 'user_providers.dart';

final transactionServiceProvider = Provider<TransactionService?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;
  return TransactionService(ref.watch(firestoreProvider), user.uid);
});

final transactionsStreamProvider =
    StreamProvider<List<TransactionEntry>>((ref) {
  final svc = ref.watch(transactionServiceProvider);
  if (svc == null) return const Stream.empty();
  return svc.watch();
});
