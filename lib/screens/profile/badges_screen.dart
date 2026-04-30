import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _BadgeData {
  const _BadgeData({
    required this.label,
    required this.icon,
    required this.tier,
    this.color,
    this.locked = false,
    this.xpReward,
    this.description,
  });

  final String label;
  final IconData icon;
  final String tier;
  final Color? color;
  final bool locked;
  final int? xpReward;
  final String? description;
}

// ---------------------------------------------------------------------------
// Badges Screen
// ---------------------------------------------------------------------------

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  // All badges — mirrors the rank screen tiers:
  // Diamond Governor → Platinum King → Pro Trader → Silver Knight → Copper Shard
  static const _allBadges = <_BadgeData>[
    // ── Unlocked ──────────────────────────────────────────────────────────
    _BadgeData(
      label: 'Saver',
      icon: Icons.savings,
      tier: 'Copper Shard',
      color: AppColors.primary,
      xpReward: 100,
      description: 'Saved money for the first time.',
    ),
    _BadgeData(
      label: 'Silver Knight',
      icon: Icons.shield,
      tier: 'Silver Knight',
      color: AppColors.textMuted,
      xpReward: 200,
      description: 'Completed 10 quests.',
    ),
    _BadgeData(
      label: 'Investor',
      icon: Icons.trending_up,
      tier: 'Pro Trader',
      color: AppColors.warning,
      xpReward: 300,
      description: 'Logged an investment for the first time.',
    ),
    // ── Locked ────────────────────────────────────────────────────────────
    _BadgeData(
      label: 'Guardian',
      icon: Icons.lock,
      tier: 'Pro Trader',
      locked: true,
      description: 'Keep a streak for 30 days.',
    ),
    _BadgeData(
      label: 'Millionaire',
      icon: Icons.lock,
      tier: 'Platinum King',
      locked: true,
      description: 'Reach a net worth of \$1,000,000.',
    ),
    _BadgeData(
      label: 'Diamond Governor',
      icon: Icons.lock,
      tier: 'Diamond Governor',
      locked: true,
      description: 'Reach the highest rank.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unlocked = _allBadges.where((b) => !b.locked).toList();
    final locked = _allBadges.where((b) => b.locked).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _Header(onBack: () {
              if (context.canPop()) context.pop();
            }),
            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                children: [
                  // Earned badges
                  const _SectionTitle(title: 'Earned Badges'),
                  const SizedBox(height: 12),
                  _BadgesGrid(badges: unlocked),
                  const SizedBox(height: 28),

                  // Locked badges
                  const _SectionTitle(title: 'Locked Badges'),
                  const SizedBox(height: 12),
                  _BadgesGrid(badges: locked),
                ],
              ),
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
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: onBack,
            ),
          ),
          const Text(
            'My Badges',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badges Grid
// ---------------------------------------------------------------------------

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid({required this.badges});

  final List<_BadgeData> badges;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) => _BadgeCard(badge: badges[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge Card
// ---------------------------------------------------------------------------

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    final color = badge.color ?? AppColors.textMuted;
    final isLocked = badge.locked;

    return GestureDetector(
      onTap: () => _showBadgeDetail(context, badge),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? AppColors.textMuted.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLocked
                    ? AppColors.background
                    : color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLocked
                      ? AppColors.textMuted.withValues(alpha: 0.35)
                      : color.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                badge.icon,
                color: isLocked ? AppColors.textMuted : color,
                size: 22,
              ),
            ),
            const SizedBox(height: 9),
            // Label
            Text(
              badge.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLocked ? AppColors.textMuted : AppColors.textPrimary,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            // Tier chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isLocked
                    ? AppColors.background
                    : color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge.tier,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isLocked ? AppColors.textMuted : color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge Detail Bottom Sheet
// ---------------------------------------------------------------------------

void _showBadgeDetail(BuildContext context, _BadgeData badge) {
  final color = badge.color ?? AppColors.textMuted;
  final isLocked = badge.locked;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cardSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppColors.background
                      : color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLocked
                        ? AppColors.textMuted.withValues(alpha: 0.4)
                        : color.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  badge.icon,
                  color: isLocked ? AppColors.textMuted : color,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                badge.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              // Tier
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppColors.background
                      : color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge.tier,
                  style: TextStyle(
                    color: isLocked ? AppColors.textMuted : color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              if (badge.description != null)
                Text(
                  badge.description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              // XP reward (only for unlocked)
              if (!isLocked && badge.xpReward != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF20232C), thickness: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${badge.xpReward} XP earned',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
