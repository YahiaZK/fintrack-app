import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/level.dart';
import '../../utils/ranks.dart';

enum _RankState { locked, current, completed }

class RanksScreen extends ConsumerWidget {
  const RanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(userProfileStreamProvider).value?.xp ?? 100;
    final level = levelFromXp(xp).clamp(1, kRanks.length);
    final currentRank = rankForLevel(level);
    final atCap = levelFromXp(xp) > kRanks.length;
    final progress = atCap ? 1.0 : progressInLevel(xp);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              onBack: () {
                if (context.canPop()) context.pop();
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your level and rank',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CurrentRankCard(
                    rank: currentRank,
                    xp: xp,
                    progress: progress,
                  ),
                  const SizedBox(height: 14),
                  _RankPathCard(ranks: kRanks, current: currentRank),
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
      padding: const EdgeInsets.fromLTRB(4, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            onPressed: onBack,
          ),
          const Text(
            'Ranks',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Current Rank Card
// ---------------------------------------------------------------------------

class _CurrentRankCard extends StatelessWidget {
  const _CurrentRankCard({
    required this.rank,
    required this.xp,
    required this.progress,
  });

  final RankData rank;
  final int xp;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262A36)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _RankBadge(rank: rank, state: _RankState.current, large: true),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rank.name,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${rank.level}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                'XP: ${_fmt(xp)} / ${_fmt(rank.xpRequired)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rank Path Card
// ---------------------------------------------------------------------------

class _RankPathCard extends StatelessWidget {
  const _RankPathCard({required this.ranks, required this.current});

  final List<RankData> ranks;
  final RankData current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B303D)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: const Alignment(-0.62, 0),
              child: Container(width: 1.5, color: const Color(0xFF303542)),
            ),
          ),
          Column(
            children: [
              for (final rank in ranks) ...[
                _RankPathRow(rank: rank, state: _stateFor(rank)),
                if (rank != ranks.last) const SizedBox(height: 22),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _RankState _stateFor(RankData rank) {
    if (rank.level == current.level) return _RankState.current;
    if (rank.level < current.level) return _RankState.completed;
    return _RankState.locked;
  }
}

class _RankPathRow extends StatelessWidget {
  const _RankPathRow({required this.rank, required this.state});

  final RankData rank;
  final _RankState state;

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == _RankState.current;
    final isLocked = state == _RankState.locked;

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Center(
            child: _RankBadge(rank: rank, state: state),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rank.name,
                style: TextStyle(
                  color: isLocked
                      ? AppColors.textPrimary.withValues(alpha: 0.2)
                      : isCurrent
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: isCurrent ? 16 : 15,
                  fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Level ${rank.level}',
                style: TextStyle(
                  color: isLocked
                      ? AppColors.textPrimary.withValues(alpha: 0.2)
                      : isCurrent
                      ? AppColors.primary.withValues(alpha: 0.85)
                      : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'You are here',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.state,
    this.large = false,
  });

  final RankData rank;
  final _RankState state;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 64.0 : 48.0;
    final iconSize = large ? 30.0 : 24.0;
    final isLocked = state == _RankState.locked;
    final isCurrent = state == _RankState.current;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.background,
        borderRadius: BorderRadius.circular(large ? 8 : 7),
        border: Border.all(
          color: isLocked
              ? AppColors.textMuted.withValues(alpha: 0.08)
              : isCurrent
              ? AppColors.primary
              : rank.color.withValues(alpha: 0.45),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        isLocked ? Icons.lock_outline_rounded : rank.icon,
        color: isLocked
            ? AppColors.textMuted.withValues(alpha: 0.16)
            : isCurrent
            ? AppColors.primary
            : rank.color,
        size: iconSize,
      ),
    );
  }
}

String _fmt(int v) {
  return v.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}
