import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Header()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              sliver: SliverList.list(
                children: [
                  const _SectionHeader(
                    title: 'Daily Quests',
                    subtitle: 'Renews in 04:20:15',
                    accent: AppColors.warning,
                  ),
                  const SizedBox(height: 12),
                  _ProgressQuestCard(
                    title: 'Coffee Saver',
                    description: 'Avoid buying coffee outside today',
                    xp: 200,
                    progress: 0.05,
                    progressLabel: '0/1',
                    progressColor: AppColors.warning,
                  ),
                  const SizedBox(height: 12),
                  _ProgressQuestCard(
                    title: 'Expense Logger',
                    description: 'Log 3 purchases today',
                    completed: true,
                    progress: 1,
                    progressLabel: '3/3',
                    progressColor: AppColors.primary,
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader(
                    title: 'Weekly Quests',
                    subtitle: 'Deadline: Sunday',
                    accent: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 12),
                  _ProgressQuestCard(
                    title: 'Disciplined Investor',
                    description: 'Deposit 500 in your investment wallet',
                    xp: 1500,
                    progress: 0.5,
                    progressLabel: '250/500',
                    progressColor: AppColors.level,
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader(
                    title: 'Habit Quests',
                    subtitle: 'Break bad habits to gain power',
                    accent: AppColors.danger,
                  ),
                  const SizedBox(height: 12),
                  const _HabitCard(
                    title: 'Coffee Killer',
                    subtitle: 'Streak: 5 days •••',
                    icon: Icons.local_cafe,
                    iconColor: AppColors.danger,
                    statusLabel: 'Done today',
                    statusColor: AppColors.danger,
                  ),
                  const SizedBox(height: 12),
                  const _HabitCard(
                    title: 'Fast food challenge',
                    subtitle: 'No fast food for a week',
                    icon: Icons.fastfood,
                    iconColor: AppColors.danger,
                    statusLabel: 'Failed',
                    statusColor: AppColors.danger,
                    statusOutlined: true,
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
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'View all',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressQuestCard extends StatelessWidget {
  const _ProgressQuestCard({
    required this.title,
    required this.description,
    this.xp,
    required this.progress,
    required this.progressLabel,
    required this.progressColor,
    this.completed = false,
  });

  final String title;
  final String description;
  final int? xp;
  final double progress;
  final String progressLabel;
  final Color progressColor;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final mutedTitle = completed ? AppColors.textMuted : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: mutedTitle,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: completed
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              if (completed)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check,
                    color: AppColors.primary,
                    size: 18,
                  ),
                )
              else if (xp != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${_formatXp(xp!)} XP',
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                progressLabel,
                style: TextStyle(
                  color: progressColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation(progressColor),
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

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.statusLabel,
    required this.statusColor,
    this.statusOutlined = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String statusLabel;
  final Color statusColor;
  final bool statusOutlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 22),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: statusOutlined ? Colors.transparent : statusColor,
              border: statusOutlined
                  ? Border.all(color: statusColor, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusOutlined ? statusColor : AppColors.textPrimary,
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

String _formatXp(int n) {
  return n.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}
