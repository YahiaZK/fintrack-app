import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/chat_message.dart';
import '../../models/transaction_entry.dart';
import '../../models/transaction_proposal.dart';
import '../../providers/chat_providers.dart';
import '../../providers/transaction_providers.dart';
import '../../theme/app_colors.dart';

const _chatId = 'default';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSend() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    await ref.read(chatComposerProvider.notifier).send(_chatId, text);
    _scrollToBottom();
  }

  Future<void> _onConfirmProposal(ChatMessage msg) async {
    final txSvc = ref.read(transactionServiceProvider);
    final chatSvc = ref.read(chatServiceProvider);
    final proposal = msg.proposal;
    if (txSvc == null || chatSvc == null || proposal == null) return;
    try {
      final txId = await txSvc.create(
        name: proposal.name,
        amount: proposal.amount,
        type: proposal.type,
        category: proposal.category,
        date: proposal.date,
      );
      await chatSvc.markProposalConfirmed(_chatId, msg.id, txId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    }
  }

  Future<void> _onRejectProposal(ChatMessage msg) async {
    final chatSvc = ref.read(chatServiceProvider);
    if (chatSvc == null) return;
    await chatSvc.markProposalRejected(_chatId, msg.id);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<ChatMessage>>>(
      chatMessagesProvider(_chatId),
      (_, __) => _scrollToBottom(),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              onClose: () {
                if (context.canPop()) context.pop();
              },
            ),
            Expanded(
              child: _ChatBody(
                scrollController: _scrollController,
                onConfirm: _onConfirmProposal,
                onReject: _onRejectProposal,
              ),
            ),
            _Composer(
              controller: _textController,
              onSend: _onSend,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF101622),
        border: Border(bottom: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: Row(
        children: [
          _StreakChip(days: 5),
          const Spacer(),
          const Text(
            'AI Assistant',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.45),
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              '\$',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$days streak',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.warning,
            size: 15,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat Body
// ---------------------------------------------------------------------------

class _ChatBody extends ConsumerWidget {
  const _ChatBody({
    required this.scrollController,
    required this.onConfirm,
    required this.onReject,
  });

  final ScrollController scrollController;
  final Future<void> Function(ChatMessage) onConfirm;
  final Future<void> Function(ChatMessage) onReject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatMessagesProvider(_chatId));
    final composer = ref.watch(chatComposerProvider);

    return Container(
      color: const Color(0xFF080B10),
      child: messagesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load chat: $e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
        ),
        data: (messages) {
          if (messages.isEmpty && !composer.sending) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Ask about your budget, savings, or next quest.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF667086),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            itemCount: messages.length + (composer.sending ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == messages.length) {
                return const _TypingBubble();
              }
              final msg = messages[index];
              return _MessageBubble(
                message: msg,
                onConfirm: () => onConfirm(msg),
                onReject: () => onReject(msg),
              );
            },
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onConfirm,
    required this.onReject,
  });

  final ChatMessage message;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isUser ? AppColors.primary : const Color(0xFF1A2233);
    final textColor =
        isUser ? AppColors.background : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: align,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              if (message.proposal != null) ...[
                const SizedBox(height: 8),
                _ProposalCard(
                  proposal: message.proposal!,
                  status: message.status ?? ProposalStatus.pending,
                  onConfirm: onConfirm,
                  onReject: onReject,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.proposal,
    required this.status,
    required this.onConfirm,
    required this.onReject,
  });

  final TransactionProposal proposal;
  final ProposalStatus status;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isIncome = proposal.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.primary : AppColors.warning;
    final sign = isIncome ? '+' : '-';
    final dateLabel = _formatDate(proposal.date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C3548)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: amountColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  proposal.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$sign\$${proposal.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetaChip(label: proposal.category),
              const SizedBox(width: 8),
              _MetaChip(label: dateLabel),
            ],
          ),
          const SizedBox(height: 12),
          _ProposalActions(
            status: status,
            onConfirm: onConfirm,
            onReject: onReject,
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _ProposalActions extends StatelessWidget {
  const _ProposalActions({
    required this.status,
    required this.onConfirm,
    required this.onReject,
  });

  final ProposalStatus status;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ProposalStatus.confirmed:
        return Row(
          children: const [
            Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 16),
            SizedBox(width: 6),
            Text(
              'Logged',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      case ProposalStatus.rejected:
        return const Text(
          'Dismissed',
          style: TextStyle(
            color: Color(0xFF667086),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      case ProposalStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF34425E)),
                  foregroundColor: AppColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF121B31),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2C3548)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2233),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Thinking...',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composer
// ---------------------------------------------------------------------------

class _Composer extends ConsumerWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sending = ref.watch(chatComposerProvider).sending;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF080B10),
        border: Border(top: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: Column(
        children: [
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF121B31),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF32425F)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: !sending,
                    onSubmitted: (_) => onSend(),
                    textInputAction: TextInputAction.send,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Record your expense...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 18),
                const Icon(
                  Icons.mic_none_rounded,
                  color: Color(0xFF8090AD),
                  size: 25,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: sending ? null : onSend,
                    icon: sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: AppColors.background,
                            size: 20,
                          ),
                    label: Text(
                      sending ? 'Sending...' : 'Send',
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF08C789),
                      elevation: 12,
                      shadowColor: AppColors.primary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2A44),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF34425E)),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.photo_camera_outlined,
                    color: Color(0xFFB7C5D9),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
