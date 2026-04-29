import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/quest.dart';
import '../../providers/quest_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/quest_icons.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(questsStreamProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: questsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load quests: $e',
                style: const TextStyle(color: AppColors.danger),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (quests) {
            final daily = _byFrequency(quests, 'daily');
            final weekly = _byFrequency(quests, 'weekly');
            final habit = _byFrequency(quests, 'habit');
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _Header()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  sliver: SliverList.list(
                    children: [
                      const _SectionHeader(
                        title: 'Daily Quests',
                        subtitle: 'Resets every day',
                        accent: AppColors.warning,
                      ),
                      const SizedBox(height: 12),
                      ..._buildList(daily),
                      const SizedBox(height: 28),
                      const _SectionHeader(
                        title: 'Weekly Quests',
                        subtitle: 'Resets every week',
                        accent: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 12),
                      ..._buildList(weekly),
                      const SizedBox(height: 28),
                      const _SectionHeader(
                        title: 'Habit Quests',
                        subtitle: 'Break bad habits to gain power',
                        accent: AppColors.danger,
                      ),
                      const SizedBox(height: 12),
                      ..._buildList(habit),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Quest> _byFrequency(List<Quest> quests, String frequency) {
    return quests
        .where((q) => (q.frequency ?? '').toLowerCase() == frequency)
        .toList();
  }

  List<Widget> _buildList(List<Quest> quests) {
    if (quests.isEmpty) {
      return const [_EmptyCategory()];
    }
    final widgets = <Widget>[];
    for (var i = 0; i < quests.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: 12));
      widgets.add(_QuestCard(quest: quests[i]));
    }
    return widgets;
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: Row(
        children: [
          const Text(
            'Quest Board',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.bolt, color: AppColors.primary, size: 14),
                SizedBox(width: 4),
                Text(
                  '1,250 XP today',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 36,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              iconForCategory(quest.category),
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (quest.category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    quest.category,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${_formatXp(quest.xp)} XP',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Text(
        'No Quests for this Category',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formatXp(int n) {
  return n.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}
