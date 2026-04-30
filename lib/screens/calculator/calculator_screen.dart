import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import '../../theme/app_colors.dart';

// ─── US Average Monthly Costs (2024 data) ────────────────────────────────────
// Sources: BLS Consumer Expenditure Survey, EIA, USDA, AAA
class _UsAverages {
  // Food: USDA moderate-cost plan ~$400/month for one adult
  static const double monthlyFood = 400.0;

  // Transport: AAA avg car ownership ~$12,182/yr = ~$1,015/mo
  // We use a commuter-only figure for fairness: gas+insurance split = ~$400/mo
  static const double monthlyTransport = 400.0;

  // Electricity: EIA avg residential ~$137/mo
  static const double monthlyElectricity = 137.0;

  // Internet: FCC/BroadbandNow avg ~$64/mo
  static const double monthlyInternet = 64.0;

  // Rent: Census Bureau median asking rent ~$1,400/mo
  static const double monthlyRent = 1400.0;

  // Healthcare: KFF avg individual premium + OOP ~$500/mo
  static const double monthlyHealthcare = 500.0;

  // Leisure budget assumption: ~15% of avg take-home ($4,000/mo) = $600
  static const double monthlyLeisure = 600.0;

  static double get dailyFood => monthlyFood / 30;
  static double get dailyTransport => monthlyTransport / 30;
  static double get dailyElectricity => monthlyElectricity / 30;
  static double get dailyInternet => monthlyInternet / 30;
  static double get dailyRent => monthlyRent / 30;
  static double get dailyHealthcare => monthlyHealthcare / 30;
}

// ─── Calculation Logic ────────────────────────────────────────────────────────
class _CalcResult {
  final double price;
  final double foodDays;
  final double transportDays;
  final double electricityDays;
  final double internetDays;
  final double rentDays;
  final double healthcareDays;
  final double leisurePercent;
  final String riskLevel;   // 'low' | 'medium' | 'high'
  final String riskLabel;
  final String riskMessage;
  final List<_SacrificeOption> sacrifices;
  final int xpReward;

  const _CalcResult({
    required this.price,
    required this.foodDays,
    required this.transportDays,
    required this.electricityDays,
    required this.internetDays,
    required this.rentDays,
    required this.healthcareDays,
    required this.leisurePercent,
    required this.riskLevel,
    required this.riskLabel,
    required this.riskMessage,
    required this.sacrifices,
    required this.xpReward,
  });
}

class _SacrificeOption {
  final String label;
  final Color color;
  const _SacrificeOption(this.label, this.color);
}

_CalcResult _calculate(double price) {
  final foodDays = price / _UsAverages.dailyFood;
  final transportDays = price / _UsAverages.dailyTransport;
  final electricityDays = price / _UsAverages.dailyElectricity;
  final internetDays = price / _UsAverages.dailyInternet;
  final rentDays = price / _UsAverages.dailyRent;
  final healthcareDays = price / _UsAverages.dailyHealthcare;
  final leisurePercent = (price / _UsAverages.monthlyLeisure).clamp(0.0, 1.0);
  final leisurePct = leisurePercent * 100;

  String riskLevel, riskLabel, riskMessage;
  int xpReward;

  if (leisurePct <= 20) {
    riskLevel = 'low';
    riskLabel = 'Smart spend!';
    riskMessage = 'This is only ${leisurePct.toStringAsFixed(0)}% of your monthly leisure budget. Looks manageable!';
    xpReward = 100;
  } else if (leisurePct <= 50) {
    riskLevel = 'medium';
    riskLabel = 'Think twice!';
    riskMessage = 'This would consume ${leisurePct.toStringAsFixed(0)}% of your leisure budget for this month.';
    xpReward = 300;
  } else if (leisurePct <= 80) {
    riskLevel = 'high';
    riskLabel = 'Risky decision!';
    riskMessage = 'This may use up to ${leisurePct.toStringAsFixed(0)}% of your leisure budget for this month.';
    xpReward = 600;
  } else {
    riskLevel = 'high';
    riskLabel = 'Danger zone!';
    riskMessage = 'This exceeds your entire monthly leisure budget (${leisurePct.toStringAsFixed(0)}%). Reconsider!';
    xpReward = 800;
  }

  // Dynamic sacrifice suggestions based on price range
  final sacrifices = <_SacrificeOption>[];
  if (price < 20) {
    sacrifices.addAll([
      const _SacrificeOption('A coffee subscription', AppColors.warning),
      const _SacrificeOption('A streaming service day', AppColors.danger),
      const _SacrificeOption('Lunch out', AppColors.primary),
    ]);
  } else if (price < 100) {
    sacrifices.addAll([
      const _SacrificeOption('Membership upgrade', AppColors.warning),
      const _SacrificeOption('A stock in your portfolio', AppColors.danger),
      const _SacrificeOption('Emergency savings', AppColors.primary),
    ]);
  } else if (price < 500) {
    sacrifices.addAll([
      const _SacrificeOption('Monthly investment', AppColors.warning),
      const _SacrificeOption('Vacation fund', AppColors.danger),
      const _SacrificeOption('3 months of internet', AppColors.primary),
    ]);
  } else {
    sacrifices.addAll([
      const _SacrificeOption('Month of rent', AppColors.warning),
      const _SacrificeOption('Emergency fund goal', AppColors.danger),
      const _SacrificeOption('Stock portfolio contribution', AppColors.primary),
    ]);
  }

  return _CalcResult(
    price: price,
    foodDays: foodDays,
    transportDays: transportDays,
    electricityDays: electricityDays,
    internetDays: internetDays,
    rentDays: rentDays,
    healthcareDays: healthcareDays,
    leisurePercent: leisurePercent,
    riskLevel: riskLevel,
    riskLabel: riskLabel,
    riskMessage: riskMessage,
    sacrifices: sacrifices,
    xpReward: xpReward,
  );
}

String _formatDays(double days) {
  if (days < 1) {
    final hours = (days * 24).round();
    return '${hours}h';
  } else if (days < 10) {
    return '${days.toStringAsFixed(1)}d';
  } else {
    return '${days.toStringAsFixed(0)}d';
  }
}

// ─── Widget ───────────────────────────────────────────────────────────────────
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  _CalcResult? _result;

  void _onPriceChanged(String value) {
    final price = double.tryParse(value);
    setState(() {
      _result = (price != null && price > 0) ? _calculate(price) : null;
    });
  }

  void _reset() {
    _itemController.clear();
    _priceController.clear();
    setState(() => _result = null);
  }

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
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
                  const _TitleBlock(),
                  const SizedBox(height: 20),
                  _FormCard(
                    itemController: _itemController,
                    priceController: _priceController,
                    onPriceChanged: _onPriceChanged,
                  ),
                  if (result != null) ..._buildResults(result),
                  if (result == null)
                    _buildEmptyState(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: const [
          Icon(Icons.calculate_outlined, color: AppColors.textMuted, size: 48),
          SizedBox(height: 12),
          Text(
            'Enter a price to see\nyour reality check',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResults(_CalcResult result) {
    return [
      const SizedBox(height: 24),
      const _SectionTitle('How many days of essentials does this cost?'),
      const SizedBox(height: 6),
      Text(
        'Based on US averages (2024)',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
      ),
      const SizedBox(height: 12),
      // First row: Food & Transport
      Row(
        children: [
          Expanded(
            child: _EquivalenceCard(
              label: 'Food',
              value: _formatDays(result.foodDays),
              subtitle: '\${_UsAverages.dailyFood.toStringAsFixed(0)}/day avg',
              icon: Icons.restaurant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _EquivalenceCard(
              label: 'Transport',
              value: _formatDays(result.transportDays),
              subtitle: '\${_UsAverages.dailyTransport.toStringAsFixed(0)}/day avg',
              icon: Icons.directions_car_filled,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // Second row: Electricity & Internet
      Row(
        children: [
          Expanded(
            child: _EquivalenceCard(
              label: 'Electricity',
              value: _formatDays(result.electricityDays),
              subtitle: '\${_UsAverages.dailyElectricity.toStringAsFixed(1)}/day avg',
              icon: Icons.bolt,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _EquivalenceCard(
              label: 'Internet',
              value: _formatDays(result.internetDays),
              subtitle: '\${_UsAverages.dailyInternet.toStringAsFixed(1)}/day avg',
              icon: Icons.wifi,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // Third row: Rent & Healthcare
      Row(
        children: [
          Expanded(
            child: _EquivalenceCard(
              label: 'Rent',
              value: _formatDays(result.rentDays),
              subtitle: '\${_UsAverages.dailyRent.toStringAsFixed(0)}/day avg',
              icon: Icons.home_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _EquivalenceCard(
              label: 'Healthcare',
              value: _formatDays(result.healthcareDays),
              subtitle: '\${_UsAverages.dailyHealthcare.toStringAsFixed(0)}/day avg',
              icon: Icons.health_and_safety_outlined,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      const _SectionTitle('What will you sacrifice?'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: result.sacrifices
            .map((s) => _SacrificeChip(label: s.label, color: s.color))
            .toList(),
      ),
      const SizedBox(height: 24),
      _ChallengeBanner(xp: result.xpReward),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(
                  color: AppColors.level,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Proceed',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _reset,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Skip it'),
            ),
          ),
        ],
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'FinTrack',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Should I buy this?',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'A reality check for your next purchase.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.itemController,
    required this.priceController,
    required this.onPriceChanged,
  });

  final TextEditingController itemController;
  final TextEditingController priceController;
  final ValueChanged<String> onPriceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Item name',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: itemController,
            decoration: InputDecoration(
              hintText: 'What do you want to buy?',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textMuted.withValues(alpha: 0.25),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textMuted.withValues(alpha: 0.25),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Price',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            onChanged: onPriceChanged,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 18,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 6),
                child: Icon(
                  Icons.attach_money,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textMuted.withValues(alpha: 0.25),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textMuted.withValues(alpha: 0.25),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
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

class _EquivalenceCard extends StatelessWidget {
  const _EquivalenceCard({
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SacrificeChip extends StatelessWidget {
  const _SacrificeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.result});

  final _CalcResult result;

  Color get _borderColor {
    switch (result.riskLevel) {
      case 'low': return AppColors.primary;
      case 'medium': return AppColors.warning;
      default: return AppColors.danger;
    }
  }

  IconData get _icon {
    switch (result.riskLevel) {
      case 'low': return Icons.check_circle_outline;
      case 'medium': return Icons.info_outline;
      default: return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _borderColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(_icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.riskLabel,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.riskMessage,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: result.leisurePercent,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(result.leisurePercent * 100).toStringAsFixed(0)}% of monthly leisure budget (\${_UsAverages.monthlyLeisure.toStringAsFixed(0)} avg)',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ChallengeBanner extends StatelessWidget {
  const _ChallengeBanner({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            color: AppColors.level,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Resilience Challenge',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Text(
            'Resist temptation: ',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          Text(
            '+$xp XP',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
