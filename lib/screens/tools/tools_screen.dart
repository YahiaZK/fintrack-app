import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/level.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(userProfileStreamProvider).value?.xp ?? 100;
    final userLevel = levelFromXp(xp);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Header()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              sliver: SliverList.list(
                children: [
                  _ToolCard(
                    levelLabel: 'Level 1',
                    title: 'Transaction Manager',
                    description:
                        'Track income & expenses to keep your budget accurate.',
                    lessonLine: 'Every dirham counts when tracked.',
                    tag: 'Basic',
                    icon: Icons.account_balance_wallet,
                    locked: userLevel < 1,
                    onTap: () => context.push('/tools/transaction-manager'),
                  ),
                  const SizedBox(height: 28),
                  _ToolCard(
                    levelLabel: 'Level 5',
                    title: '',
                    description: 'Unlocks at level 5',
                    lessonLine: '',
                    tag: '',
                    icon: Icons.lock,
                    locked: userLevel < 5,
                  ),
                  const SizedBox(height: 28),
                  _ToolCard(
                    levelLabel: 'Level 10',
                    title: '',
                    description: 'Unlocks at level 10',
                    lessonLine: '',
                    tag: '',
                    icon: Icons.lock,
                    locked: userLevel < 10,
                  ),
                  const SizedBox(height: 28),
                  _ToolCard(
                    levelLabel: 'Level 20',
                    title: '',
                    description: 'Unlocks at level 20',
                    lessonLine: '',
                    tag: '',
                    icon: Icons.lock,
                    locked: userLevel < 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(userProfileStreamProvider).value?.xp ?? 100;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF20232C), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'My Financial Tools',
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
              children: [
                const Icon(Icons.bolt, color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${_formatXp(xp)} XP',
                  style: const TextStyle(
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

String _formatXp(int n) {
  return n.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.levelLabel,
    required this.title,
    required this.description,
    required this.lessonLine,
    required this.tag,
    required this.icon,
    required this.locked,
    this.onTap,
  });

  final String levelLabel;
  final String title;
  final String description;
  final String lessonLine;
  final String tag;
  final IconData icon;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = locked
        ? _LockedBody(description: description)
        : _UnlockedBody(
            title: title,
            description: description,
            lessonLine: lessonLine,
            tag: tag,
            icon: icon,
          );
    final wrappedBody = (!locked && onTap != null)
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: body,
            ),
          )
        : body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: locked
                  ? AppColors.cardSurface
                  : AppColors.primary.withValues(alpha: 0.18),
              border: Border.all(
                color: locked
                    ? AppColors.textMuted.withValues(alpha: 0.4)
                    : AppColors.primary,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              levelLabel,
              style: TextStyle(
                color: locked ? AppColors.textMuted : AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: wrappedBody,
          ),
        ),
      ],
    );
  }
}

class _UnlockedBody extends StatelessWidget {
  const _UnlockedBody({
    required this.title,
    required this.description,
    required this.lessonLine,
    required this.tag,
    required this.icon,
  });

  final String title;
  final String description;
  final String lessonLine;
  final String tag;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (tag.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Spacer(),
              Icon(icon, color: AppColors.primary, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Lesson: ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: lessonLine,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
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

class _LockedBody extends StatelessWidget {
  const _LockedBody({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.textMuted.withValues(alpha: 0.55),
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
