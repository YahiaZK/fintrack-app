import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../components/onboarding/hero_badge.dart';
import '../../components/onboarding/onboarding_scaffold.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/app_colors.dart';

class OnboardingExpensesScreen extends ConsumerStatefulWidget {
  const OnboardingExpensesScreen({super.key});

  @override
  ConsumerState<OnboardingExpensesScreen> createState() =>
      _OnboardingExpensesScreenState();
}

class _OnboardingExpensesScreenState
    extends ConsumerState<OnboardingExpensesScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final raw = _controller.text.trim();
    final value = double.tryParse(raw);
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
      return;
    }
    setState(() => _saving = true);
    final notifier = ref.read(onboardingControllerProvider.notifier);
    notifier.setExpenses(value);
    try {
      await notifier.finalize();
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      stepIndex: 2,
      hero: const HeroBadge(
        child: Icon(
          Icons.trending_down_rounded,
          size: 76,
          color: AppColors.primary,
        ),
      ),
      fieldLabel: 'What are your expenses?',
      field: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.done,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        onSubmitted: (_) => _finish(),
        decoration: const InputDecoration(hintText: 'Current month expenses'),
      ),
      ctaLabel: _saving ? '...' : 'Start your journey',
      onCta: _saving ? null : _finish,
    );
  }
}
