import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/chat_message.dart';

class ChatService {
  ChatService(this._firestore, this._functions, this._uid);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final String _uid;

  CollectionReference<Map<String, dynamic>> _messagesCol(String chatId) =>
      _firestore
          .collection('users')
          .doc(_uid)
          .collection('chats')
          .doc(chatId)
          .collection('messages');

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _messagesCol(chatId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatMessage.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> sendMessage(String chatId, String text) async {
    final callable = _functions.httpsCallable('chatWithAssistant');
    await callable.call(<String, dynamic>{
      'chatId': chatId,
      'message': text,
    });
  }

  Future<void> markProposalConfirmed(
    String chatId,
    String messageId,
    String transactionId,
  ) {
    return _messagesCol(chatId).doc(messageId).update({
      'status': 'confirmed',
      'transactionId': transactionId,
    });
  }

  Future<void> markProposalRejected(String chatId, String messageId) {
    return _messagesCol(chatId).doc(messageId).update({
      'status': 'rejected',
    });
  }
}
