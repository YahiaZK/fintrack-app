import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/goal.dart';
import '../../models/quest.dart';
import '../../providers/goal_providers.dart';
import '../../providers/quest_providers.dart';
import '../../providers/user_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/quest_icons.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final questsAsync = ref.watch(questsStreamProvider);
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Something went wrong: $e',
              style: const TextStyle(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (profile) {
          final name = profile?.name ?? 'New Warrior';
          final income = profile?.monthlyIncome ?? 0;
          final expenses = profile?.monthlyExpenses ?? 0;
          final balance = income - expenses;
          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _Header()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList.list(
                    children: [
                      _ProfileCard(
                        name: name,
                        onTap: () => context.go('/home/profile'),
                      ),
                      const SizedBox(height: 14),
                      _BalanceCard(amount: balance),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStatCard(
                              label: 'Saved',
                              amount: balance > 0 ? balance : 0,
                              icon: Icons.savings_outlined,
                              accent: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniStatCard(
                              label: 'Spent',
                              amount: expenses,
                              icon: Icons.trending_down_rounded,
                              accent: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: "Today's Quests",
                        action: 'View all',
                        onActionTap: () => context.go('/quests'),
                      ),
                      const SizedBox(height: 12),
                      _QuestsSection(questsAsync: questsAsync),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: 'Goals',
                        action: 'View all',
                        onActionTap: () => context.go('/home/goals'),
                      ),
                      const SizedBox(height: 12),
                      _GoalsSection(goalsAsync: goalsAsync),
                      const SizedBox(height: 24),
                      const _SectionHeader(title: 'Recent Transactions'),
                      const SizedBox(height: 12),
                      const _TransactionTile(
                        title: 'Starbucks',
                        subtitle: '2 hours ago',
                        amount: -28.5,
                        tag: 'Leisure',
                        icon: Icons.local_cafe,
                        iconBg: Color(0xFF3A2A22),
                        iconColor: Color(0xFFC58A6E),
                      ),
                      const SizedBox(height: 10),
                      const _TransactionTile(
                        title: 'Incoming transfer',
                        subtitle: 'Yesterday',
                        amount: 1500,
                        tag: 'Salary',
                        icon: Icons.account_balance_wallet,
                        iconBg: Color(0xFF1F2D2A),
                        iconColor: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      const _TransactionTile(
                        title: 'ADNOC Station',
                        subtitle: 'Yesterday',
                        amount: -120.0,
                        tag: '',
                        icon: Icons.local_gas_station,
                        iconBg: Color(0xFF3A2A22),
                        iconColor: Color(0xFFE0A574),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: const Center(
        child: Text(
          '8usdhf',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
        children: [
          Row(
            children: [
              _LevelHex(level: 3),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Financial Warrior Level',
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  color: AppColors.textMuted,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Stack(
              children: [
                Container(height: 4, color: AppColors.background),
                FractionallySizedBox(
                  widthFactor: 0.55,
                  child: Container(height: 4, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _LevelHex extends StatelessWidget {
  const _LevelHex({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HexClipper(),
      child: Container(
        width: 50,
        height: 56,
        color: AppColors.level,
        alignment: Alignment.center,
        child: Text(
          '$level',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w / 2, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Remaining Budget',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              Text(
                '\$${_format(amount)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.accent,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${_format(amount)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(icon, color: accent, size: 22),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onActionTap});

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (action != null)
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                action!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuestsSection extends StatelessWidget {
  const _QuestsSection({required this.questsAsync});

  final AsyncValue<List<Quest>> questsAsync;

  @override
  Widget build(BuildContext context) {
    return questsAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => _EmptyQuests(message: 'Failed to load quests'),
      data: (quests) {
        final daily = quests
            .where((q) => (q.frequency ?? '').toLowerCase() == 'daily')
            .toList();
        if (daily.isEmpty) {
          return const _EmptyQuests(message: 'No Quests for Today');
        }
        final visible = daily.take(2).toList();
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final q in visible)
              SizedBox(
                width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
                child: _QuestCard(
                  title: q.name,
                  icon: iconForCategory(q.category),
                  xp: q.xp,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyQuests extends StatelessWidget {
  const _EmptyQuests({required this.message});

  final String message;

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
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.title, required this.icon, required this.xp});

  final String title;
  final IconData icon;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.level, size: 20),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '+$xp XP',
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

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.goalsAsync});

  final AsyncValue<List<Goal>> goalsAsync;

  @override
  Widget build(BuildContext context) {
    return goalsAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) =>
          const _EmptyQuests(message: 'Failed to load goals'),
      data: (goals) {
        if (goals.isEmpty) {
          return const _EmptyQuests(message: 'No Goals yet');
        }
        final visible = goals.take(2).toList();
        return Row(
          children: [
            Expanded(child: _goalCardFor(visible[0])),
            const SizedBox(width: 12),
            Expanded(
              child: visible.length > 1
                  ? _goalCardFor(visible[1])
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Widget _goalCardFor(Goal g) {
    final progress = g.totalAmount <= 0
        ? 0.0
        : (g.currentAmount / g.totalAmount).clamp(0.0, 1.0);
    return _GoalCard(
      title: g.name,
      icon: iconForCategory(g.category),
      progress: progress,
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.icon,
    required this.progress,
  });

  final String title;
  final IconData icon;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.tag,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final double amount;
  final String tag;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final positive = amount >= 0;
    final amountColor = positive ? AppColors.primary : AppColors.danger;
    final accentBar = positive ? AppColors.primary : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: accentBar,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${positive ? '+' : ''}${_format(amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (tag.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  tag,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

String _format(double v) {
  final neg = v < 0;
  final n = v.abs();
  final hasFraction = n % 1 != 0;
  final s = hasFraction ? n.toStringAsFixed(1) : n.toStringAsFixed(0);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  final out = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  return neg ? '-$out' : out;
}
