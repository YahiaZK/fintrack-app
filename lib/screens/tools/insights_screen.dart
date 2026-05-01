import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/transaction_entry.dart';
import '../../providers/transaction_providers.dart';
import '../../providers/user_providers.dart';
import '../../theme/app_colors.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsStreamProvider);
    final profile = ref.watch(userProfileStreamProvider).value;
    final netWorth = profile?.totalNetWorth ?? 0;
    final totalSpent = profile?.totalSpent ?? 0;

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
                children: txAsync.when(
                  loading: () => const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                  error: (e, _) => [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Failed to load transactions: $e',
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ],
                  data: (list) => _buildBody(
                    list,
                    netWorth: netWorth,
                    totalSpent: totalSpent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(
    List<TransactionEntry> list, {
    required double netWorth,
    required double totalSpent,
  }) {
    return [
      _SummaryTiles(
        netWorth: netWorth,
        totalSpent: totalSpent,
        transactionCount: list.length,
      ),
      const SizedBox(height: 20),
      const _SectionTitle('Net Worth vs Total Spent'),
      const SizedBox(height: 12),
      _NetWorthVsSpentBar(netWorth: netWorth, totalSpent: totalSpent),
      const SizedBox(height: 20),
      const _SectionTitle('Spending by Category'),
      const SizedBox(height: 12),
      _CategoryDonut(transactions: list),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF20232C), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/tools');
              }
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const Spacer(),
          const Text(
            'Insights',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SummaryTiles extends StatelessWidget {
  const _SummaryTiles({
    required this.netWorth,
    required this.totalSpent,
    required this.transactionCount,
  });

  final double netWorth;
  final double totalSpent;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Net Worth',
            value: _money(netWorth),
            icon: Icons.account_balance_wallet_outlined,
            accent: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Total Spent',
            value: _money(totalSpent),
            icon: Icons.trending_down_rounded,
            accent: AppColors.danger,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Transactions',
            value: transactionCount.toString(),
            icon: Icons.receipt_long_outlined,
            accent: AppColors.level,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetWorthVsSpentBar extends StatelessWidget {
  const _NetWorthVsSpentBar({
    required this.netWorth,
    required this.totalSpent,
  });

  final double netWorth;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    final maxVal = [netWorth, totalSpent].fold<double>(
      0,
      (m, v) => v > m ? v : m,
    );
    final maxY = maxVal == 0 ? 100.0 : maxVal * 1.2;

    return _CardShell(
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: netWorth,
                        color: AppColors.primary,
                        width: 36,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: totalSpent,
                        color: AppColors.danger,
                        width: 36,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.textMuted.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final label = value.toInt() == 0
                            ? 'Net Worth'
                            : 'Spent';
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          _shortMoney(value),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryDonut extends StatelessWidget {
  const _CategoryDonut({required this.transactions});

  final List<TransactionEntry> transactions;

  static const _palette = <Color>[
    AppColors.primary,
    AppColors.danger,
    AppColors.level,
    AppColors.warning,
    Color(0xFF4FB6C9),
    Color(0xFFD17AB5),
    Color(0xFF8BC34A),
    Color(0xFFB7B7B7),
  ];

  @override
  Widget build(BuildContext context) {
    final byCategory = <String, double>{};
    for (final t in transactions) {
      if (t.type != TransactionType.expense) continue;
      byCategory.update(
        t.category.isEmpty ? 'other' : t.category,
        (v) => v + t.amount,
        ifAbsent: () => t.amount,
      );
    }
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    if (total <= 0) {
      return _CardShell(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'No expenses recorded yet',
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < entries.length; i++) {
      final color = _palette[i % _palette.length];
      sections.add(
        PieChartSectionData(
          value: entries[i].value,
          color: color,
          radius: 36,
          showTitle: false,
        ),
      );
    }

    return _CardShell(
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 48,
                sectionsSpace: 2,
                startDegreeOffset: -90,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _palette[i % _palette.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _capitalize(entries[i].key),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _money(entries[i].value),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${(entries[i].value / total * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: child,
    );
  }
}

String _money(double v) {
  final negative = v < 0;
  final abs = v.abs();
  final whole = abs.toStringAsFixed(0);
  final withCommas = whole.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '${negative ? '-' : ''}\$$withCommas';
}

String _shortMoney(double v) {
  final negative = v < 0;
  final abs = v.abs();
  String body;
  if (abs >= 1000000) {
    body = '${(abs / 1000000).toStringAsFixed(1)}M';
  } else if (abs >= 1000) {
    body = '${(abs / 1000).toStringAsFixed(1)}k';
  } else {
    body = abs.toStringAsFixed(0);
  }
  return '${negative ? '-' : ''}\$$body';
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}
