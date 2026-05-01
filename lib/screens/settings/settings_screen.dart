import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_providers.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Preferences
  String _currency = 'USD';
  String _language = 'English';
  String _numberFormat = '1,2,3,4,…';

  // Notifications
  bool _dailySummary = true;
  bool _questNotifications = true;
  bool _levelUp = true;
  bool _budgetExceeded = true;

  Future<void> _confirmResetXp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text(
          'Reset XP?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will set your XP back to 0 and reset your level. This cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final service = ref.read(userServiceProvider);
    if (service == null) return;
    try {
      await service.resetXp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('XP reset to 0')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset XP: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            _Header(onBack: () {
              if (context.canPop()) context.pop();
            }),
            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                children: [
                  // ── Account ─────────────────────────────────────────────
                  const _SectionTitle(title: 'Account'),
                  const SizedBox(height: 10),
                  profileAsync.when(
                    loading: () => const _LoadingCard(),
                    error: (_, __) => const _AccountCard(
                      name: '—',
                      income: 0,
                      expenses: 0,
                      savingGoal: 20,
                    ),
                    data: (profile) => _AccountCard(
                      name: profile?.name ?? '—',
                      income: profile?.monthlyIncome ?? 0,
                      expenses: profile?.monthlyExpenses ?? 0,
                      savingGoal: 20,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Preferences ──────────────────────────────────────────
                  const _SectionTitle(title: 'Preferences'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _PreferenceRow(
                          icon: Icons.currency_exchange_rounded,
                          label: 'Currency',
                          trailing: _currency,
                        ),
                        const _CardDivider(),
                        _PreferenceRow(
                          icon: Icons.language_rounded,
                          label: 'Language',
                          trailing: _language,
                        ),
                        const _CardDivider(),
                        _PreferenceRow(
                          icon: Icons.tag_rounded,
                          label: 'Number Format',
                          trailing: _numberFormat,
                        ),
                        const _CardDivider(),
                        _PreferenceRow(
                          icon: Icons.restart_alt_rounded,
                          label: 'Reset XP',
                          trailing: '',
                          labelColor: AppColors.danger,
                          onTap: _confirmResetXp,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Notifications ────────────────────────────────────────
                  const _SectionTitle(title: 'Notifications'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _ToggleRow(
                          label: 'Daily Summary',
                          value: _dailySummary,
                          onChanged: (v) => setState(() => _dailySummary = v),
                        ),
                        const _CardDivider(),
                        _ToggleRow(
                          label: 'Quest Challenges',
                          value: _questNotifications,
                          onChanged: (v) =>
                              setState(() => _questNotifications = v),
                        ),
                        const _CardDivider(),
                        _ToggleRow(
                          label: 'Level Up',
                          value: _levelUp,
                          onChanged: (v) => setState(() => _levelUp = v),
                        ),
                        const _CardDivider(),
                        _ToggleRow(
                          label: 'Budget Exceeded',
                          value: _budgetExceeded,
                          onChanged: (v) => setState(() => _budgetExceeded = v),
                        ),
                      ],
                    ),
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
            'Settings',
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
// Loading Placeholder
// ---------------------------------------------------------------------------

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

// ---------------------------------------------------------------------------
// Account Card
// ---------------------------------------------------------------------------

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.income,
    required this.expenses,
    required this.savingGoal,
  });

  final String name;
  final double income;
  final double expenses;
  final int savingGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _AccountRow(
            icon: Icons.person_outline_rounded,
            label: 'Username',
            value: name,
            valueColor: AppColors.textPrimary,
          ),
          const _CardDivider(),
          _AccountRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Monthly Income',
            value: '\$${_fmt(income)}',
            valueColor: AppColors.primary,
          ),
          const _CardDivider(),
          _AccountRow(
            icon: Icons.shopping_cart_outlined,
            label: 'Essentials',
            value: '\$${_fmt(expenses)}',
            valueColor: AppColors.textPrimary,
          ),
          const _CardDivider(),
          _AccountRow(
            icon: Icons.track_changes_rounded,
            label: 'Savings Goal %',
            badge: '$savingGoal%',
            valueColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.label,
    required this.valueColor,
    this.value,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String? badge;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else if (value != null)
            Text(
              value!,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preference Row
// ---------------------------------------------------------------------------

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.labelColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String trailing;
  final Color? labelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: labelColor ?? AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor ?? AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 18,
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

// ---------------------------------------------------------------------------
// Toggle Row
// ---------------------------------------------------------------------------

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.background,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFF20232C),
      indent: 16,
      endIndent: 16,
    );
  }
}

String _fmt(double v) {
  final n = v.abs();
  final hasFrac = n % 1 != 0;
  final s = hasFrac ? n.toStringAsFixed(1) : n.toStringAsFixed(0);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}
