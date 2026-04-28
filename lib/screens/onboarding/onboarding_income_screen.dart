import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../components/onboarding/hero_badge.dart';
import '../../components/onboarding/onboarding_scaffold.dart';
import '../../models/user_profile.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/app_colors.dart';

class OnboardingIncomeScreen extends ConsumerStatefulWidget {
  const OnboardingIncomeScreen({super.key});

  @override
  ConsumerState<OnboardingIncomeScreen> createState() =>
      _OnboardingIncomeScreenState();
}

class _OnboardingIncomeScreenState
    extends ConsumerState<OnboardingIncomeScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
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
    notifier.setIncome(value);
    try {
      await notifier.persistStep(UserProfile(monthlyIncome: value));
      if (!mounted) return;
      context.go('/onboarding/expenses');
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
      stepIndex: 1,
      hero: const HeroBadge(
        child: Icon(
          Icons.add_moderator_outlined,
          size: 76,
          color: AppColors.primary,
        ),
      ),
      fieldLabel: 'What is your income?',
      field: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.done,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        onSubmitted: (_) => _next(),
        decoration: const InputDecoration(hintText: 'Current month income'),
      ),
      ctaLabel: _saving ? '...' : 'Next',
      onCta: _saving ? null : _next,
    );
  }
}
