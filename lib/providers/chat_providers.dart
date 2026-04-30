import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/chat_service.dart';
import 'auth_providers.dart';
import 'user_providers.dart';

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

final chatServiceProvider = Provider<ChatService?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;
  return ChatService(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
    user.uid,
  );
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  final svc = ref.watch(chatServiceProvider);
  if (svc == null) return const Stream.empty();
  return svc.watchMessages(chatId);
});

class ChatComposerState {
  const ChatComposerState({this.sending = false, this.error});

  final bool sending;
  final String? error;

  ChatComposerState copyWith({bool? sending, Object? error = _sentinel}) {
    return ChatComposerState(
      sending: sending ?? this.sending,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  static const Object _sentinel = Object();
}

class ChatComposerController extends Notifier<ChatComposerState> {
  @override
  ChatComposerState build() => const ChatComposerState();

  Future<void> send(String chatId, String text) async {
    final svc = ref.read(chatServiceProvider);
    final trimmed = text.trim();
    if (svc == null || trimmed.isEmpty) return;
    state = state.copyWith(sending: true, error: null);
    try {
      await svc.sendMessage(chatId, trimmed);
      state = state.copyWith(sending: false);
    } catch (e) {
      state = state.copyWith(sending: false, error: e.toString());
    }
  }
}

final chatComposerProvider =
    NotifierProvider<ChatComposerController, ChatComposerState>(
  ChatComposerController.new,
);
