import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class HeroBadge extends StatelessWidget {
  const HeroBadge({
    super.key,
    required this.child,
    this.showLevel = true,
  });

  final Widget child;
  final bool showLevel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 160,
            height: 160,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardSurface,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: child,
          ),
          if (showLevel)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LVL 1',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
