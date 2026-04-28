import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'page_indicator.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.stepIndex,
    required this.hero,
    required this.fieldLabel,
    required this.field,
    required this.ctaLabel,
    required this.onCta,
    this.title = 'مرحباً بك في FinTrack',
    this.subtitle = 'تتبع مصاريفك، اكسب خبرة وارتق في المستوى.',
  });

  final int stepIndex;
  final Widget hero;
  final String fieldLabel;
  final Widget field;
  final String ctaLabel;
  final VoidCallback? onCta;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              PageIndicator(activeIndex: stepIndex),
              const SizedBox(height: 56),
              hero,
              const SizedBox(height: 40),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
              const Spacer(),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
                  child: Text(
                    fieldLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              field,
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCta,
                  child: Text(ctaLabel),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
