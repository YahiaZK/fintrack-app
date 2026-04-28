import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class FintrackLogo extends StatelessWidget {
  const FintrackLogo({super.key, this.size = 130});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.4,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.shield,
            size: size,
            color: AppColors.primary.withValues(alpha: 0.9),
          ),
          Positioned(
            top: -4,
            child: Icon(
              Icons.workspace_premium,
              size: size * 0.42,
              color: AppColors.warning,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: size * 0.18),
            child: Text(
              'FinTrack',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: size * 0.18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
