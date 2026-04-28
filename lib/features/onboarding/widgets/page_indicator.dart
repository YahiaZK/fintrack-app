import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.activeIndex,
    this.count = 3,
  });

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4,
          width: active ? 28 : 22,
          decoration: BoxDecoration(
            color: active
                ? AppColors.textPrimary
                : AppColors.textPrimary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
