import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../components/onboarding/fintrack_logo.dart';
import '../../components/onboarding/onboarding_scaffold.dart';
import '../../models/user_profile.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingNameScreen extends ConsumerStatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  ConsumerState<OnboardingNameScreen> createState() =>
      _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends ConsumerState<OnboardingNameScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال اسمك')));
      return;
    }
    setState(() => _saving = true);
    final notifier = ref.read(onboardingControllerProvider.notifier);
    notifier.setName(name);
    try {
      await notifier.persistStep(UserProfile(name: name));
      if (!mounted) return;
      context.go('/onboarding/income');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر الحفظ: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      stepIndex: 0,
      hero: const FintrackLogo(),
      fieldLabel: 'ما اسمك؟',
      field: TextField(
        controller: _controller,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _next(),
        decoration: const InputDecoration(hintText: 'أدخل اسم المحارب...'),
      ),
      ctaLabel: _saving ? '...' : 'التالي',
      onCta: _saving ? null : _next,
    );
  }
}
