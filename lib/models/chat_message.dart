import 'package:cloud_firestore/cloud_firestore.dart';

import 'transaction_proposal.dart';

enum ChatRole { user, assistant }

enum ProposalStatus { pending, confirmed, rejected }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.proposal,
    this.status,
    this.transactionId,
    this.createdAt,
  });

  final String id;
  final ChatRole role;
  final String text;
  final TransactionProposal? proposal;
  final ProposalStatus? status;
  final String? transactionId;
  final DateTime? createdAt;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> data) {
    final propRaw = data['proposal'];
    final statusStr = data['status'] as String?;
    final ts = data['createdAt'];
    return ChatMessage(
      id: id,
      role: (data['role'] as String?) == 'assistant'
          ? ChatRole.assistant
          : ChatRole.user,
      text: (data['text'] as String?) ?? '',
      proposal: propRaw is Map<String, dynamic>
          ? TransactionProposal.fromMap(propRaw)
          : null,
      status: switch (statusStr) {
        'pending' => ProposalStatus.pending,
        'confirmed' => ProposalStatus.confirmed,
        'rejected' => ProposalStatus.rejected,
        _ => null,
      },
      transactionId: data['transactionId'] as String?,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
