import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/goal.dart';
import '../../providers/goal_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/quest_icons.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);
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
                  const Text(
                    'My Savings Goals',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildGoalsSection(goalsAsync),
                  const SizedBox(height: 24),
                  _NewGoalCta(onTap: () => _openCreateGoalDialog(context, ref)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGoalsSection(AsyncValue<List<Goal>> goalsAsync) {
    return goalsAsync.when(
      loading: () => const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ],
      error: (e, _) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Failed to load goals: $e',
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ],
      data: (goals) {
        if (goals.isEmpty) return const <Widget>[];
        final widgets = <Widget>[];
        for (var i = 0; i < goals.length; i++) {
          if (i > 0) widgets.add(const SizedBox(height: 16));
          final accent = i.isEven ? AppColors.primary : AppColors.level;
          widgets.add(_GoalCard(goal: goals[i], accent: accent));
        }
        return widgets;
      },
    );
  }

  Future<void> _openCreateGoalDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<_NewGoalData>(
      context: context,
      builder: (_) => const _NewGoalDialog(),
    );
    if (result == null) return;
    try {
      await ref
          .read(goalServiceProvider)
          .create(
            name: result.name,
            category: result.category,
            totalAmount: result.totalAmount,
            currentAmount: 0,
            deadline: result.deadline,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create goal: $e')));
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF20232C), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
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
            'Savings',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal, required this.accent});

  final Goal goal;
  final Color accent;

  Future<void> _openAddAmountDialog(BuildContext context, WidgetRef ref) async {
    final amount = await showDialog<int>(
      context: context,
      builder: (_) => _AddAmountDialog(accent: accent, goalName: goal.name),
    );
    if (amount == null) return;
    try {
      await ref
          .read(goalServiceProvider)
          .addAmount(goalId: goal.id, amount: amount);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add amount: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = goal.currentAmount.toDouble();
    final total = goal.totalAmount.toDouble();
    final progress = total <= 0 ? 0.0 : (saved / total).clamp(0.0, 1.0);
    final deadlineText = goal.deadline == null
        ? 'No deadline'
        : 'Deadline: ${_formatDate(goal.deadline!)}';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border(right: BorderSide(color: accent, width: 4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deadlineText,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  iconForCategory(goal.category),
                  color: accent,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved: ${_money(saved)}',
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'of ${_money(total)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _openAddAmountDialog(context, ref),
              icon: Icon(Icons.payments_outlined, color: accent, size: 18),
              label: Text(
                'Add Amount',
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: accent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewGoalCta extends StatelessWidget {
  const _NewGoalCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.flag_outlined,
              color: AppColors.textPrimary,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Got a new financial dream?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                'Set your strategic goal now',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAmountDialog extends StatefulWidget {
  const _AddAmountDialog({required this.accent, required this.goalName});

  final Color accent;
  final String goalName;

  @override
  State<_AddAmountDialog> createState() => _AddAmountDialogState();
}

class _AddAmountDialogState extends State<_AddAmountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = int.parse(_amountCtrl.text.trim());
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add to "${widget.goalName}"',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: AppColors.textPrimary),
          validator: (v) {
            final n = int.tryParse((v ?? '').trim());
            if (n == null || n <= 0) return 'Enter an amount > 0';
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Amount to add',
            labelStyle: const TextStyle(color: AppColors.textMuted),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2A2E3A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.accent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.accent,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Add',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NewGoalDialog extends StatefulWidget {
  const _NewGoalDialog();

  @override
  State<_NewGoalDialog> createState() => _NewGoalDialogState();
}

class _NewGoalDialogState extends State<_NewGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  DateTime? _deadline;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final total = int.parse(_totalCtrl.text.trim());
    Navigator.of(context).pop(
      _NewGoalData(
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        totalAmount: total,
        deadline: _deadline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'New Savings Goal',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(
                controller: _nameCtrl,
                label: 'Name',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _categoryCtrl,
                label: 'Category (e.g. home, travel, car)',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _totalCtrl,
                label: 'Total amount',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Enter an amount > 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: _decoration('Deadline'),
                  child: Text(
                    _deadline == null ? 'Pick a date' : _formatDate(_deadline!),
                    style: TextStyle(
                      color: _deadline == null
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Create',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _decoration(label),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMuted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2A2E3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }
}

class _NewGoalData {
  const _NewGoalData({
    required this.name,
    required this.category,
    required this.totalAmount,
    this.deadline,
  });

  final String name;
  final String category;
  final int totalAmount;
  final DateTime? deadline;
}

String _money(double v) {
  final s = v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '\$$s';
}

String _formatDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
