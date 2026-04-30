import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _RankData {
  const _RankData({
    required this.name,
    required this.level,
    required this.icon,
    required this.color,
    required this.xpRequired,
  });

  final String name;
  final int level;
  final IconData icon;
  final Color color;
  final int xpRequired;
}

enum _RankState { locked, current, completed }

// ---------------------------------------------------------------------------
// Ranks Screen
// ---------------------------------------------------------------------------

class RanksScreen extends StatelessWidget {
  const RanksScreen({super.key});

  static const _currentRank = _RankData(
    name: 'Gold II',
    level: 8,
    icon: Icons.shield_rounded,
    color: Color(0xFFEF9F27),
    xpRequired: 3000,
  );

  static const _currentXp = 2450;

  static const _rankSteps = <_RankData>[
    _RankData(
      name: 'Crown',
      level: 16,
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFE7C860),
      xpRequired: 15000,
    ),
    _RankData(
      name: 'Diamond III',
      level: 15,
      icon: Icons.diamond_rounded,
      color: Color(0xFF78D6F5),
      xpRequired: 13500,
    ),
    _RankData(
      name: 'Diamond II',
      level: 14,
      icon: Icons.diamond_rounded,
      color: Color(0xFF78D6F5),
      xpRequired: 12000,
    ),
    _RankData(
      name: 'Diamond I',
      level: 13,
      icon: Icons.diamond_rounded,
      color: Color(0xFF78D6F5),
      xpRequired: 10500,
    ),
    _RankData(
      name: 'Platinum III',
      level: 12,
      icon: Icons.military_tech_rounded,
      color: Color(0xFFB8D0DC),
      xpRequired: 9000,
    ),
    _RankData(
      name: 'Platinum II',
      level: 11,
      icon: Icons.military_tech_rounded,
      color: Color(0xFFB8D0DC),
      xpRequired: 7800,
    ),
    _RankData(
      name: 'Platinum I',
      level: 10,
      icon: Icons.military_tech_rounded,
      color: Color(0xFFB8D0DC),
      xpRequired: 6600,
    ),
    _RankData(
      name: 'Gold III',
      level: 9,
      icon: Icons.shield_rounded,
      color: Color(0xFFEF9F27),
      xpRequired: 4200,
    ),
    _RankData(
      name: 'Gold II',
      level: 8,
      icon: Icons.shield_rounded,
      color: Color(0xFFEF9F27),
      xpRequired: 3000,
    ),
    _RankData(
      name: 'Gold I',
      level: 7,
      icon: Icons.shield_rounded,
      color: Color(0xFFEF9F27),
      xpRequired: 2200,
    ),
    _RankData(
      name: 'Silver III',
      level: 6,
      icon: Icons.verified_rounded,
      color: Color(0xFFC0CED7),
      xpRequired: 1600,
    ),
    _RankData(
      name: 'Silver II',
      level: 5,
      icon: Icons.verified_rounded,
      color: Color(0xFFC0CED7),
      xpRequired: 1100,
    ),
    _RankData(
      name: 'Silver I',
      level: 4,
      icon: Icons.verified_rounded,
      color: Color(0xFFC0CED7),
      xpRequired: 700,
    ),
    _RankData(
      name: 'Bronze III',
      level: 3,
      icon: Icons.savings_rounded,
      color: Color(0xFFB77B4B),
      xpRequired: 450,
    ),
    _RankData(
      name: 'Bronze II',
      level: 2,
      icon: Icons.savings_rounded,
      color: Color(0xFFB77B4B),
      xpRequired: 250,
    ),
    _RankData(
      name: 'Bronze I',
      level: 1,
      icon: Icons.savings_rounded,
      color: Color(0xFFB77B4B),
      xpRequired: 100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final progress = _currentXp / _currentRank.xpRequired;

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
                    rank: _currentRank,
                    xp: _currentXp,
                    progress: progress,
                  ),
                  const SizedBox(height: 14),
                  const _XpSourcesCard(),
                  const SizedBox(height: 14),
                  _RankPathCard(ranks: _rankSteps, current: _currentRank),
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

  final _RankData rank;
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
// XP Sources Card
// ---------------------------------------------------------------------------

class _XpSourcesCard extends StatelessWidget {
  const _XpSourcesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B303D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Text(
            'Where did XP come from today?',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 18),
          _XpSourceRow(
            icon: Icons.savings_outlined,
            label: 'Daily saving',
            xp: '+150 XP',
          ),
          SizedBox(height: 14),
          _XpSourceRow(
            icon: Icons.analytics_outlined,
            label: 'Budget analysis',
            xp: '+50 XP',
          ),
        ],
      ),
    );
  }
}

class _XpSourceRow extends StatelessWidget {
  const _XpSourceRow({
    required this.icon,
    required this.label,
    required this.xp,
  });

  final IconData icon;
  final String label;
  final String xp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          xp,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rank Path Card
// ---------------------------------------------------------------------------

class _RankPathCard extends StatelessWidget {
  const _RankPathCard({required this.ranks, required this.current});

  final List<_RankData> ranks;
  final _RankData current;

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

  _RankState _stateFor(_RankData rank) {
    if (rank.level == current.level) return _RankState.current;
    if (rank.level < current.level) return _RankState.completed;
    return _RankState.locked;
  }
}

class _RankPathRow extends StatelessWidget {
  const _RankPathRow({required this.rank, required this.state});

  final _RankData rank;
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

  final _RankData rank;
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
