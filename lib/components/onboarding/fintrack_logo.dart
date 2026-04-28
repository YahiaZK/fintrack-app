import 'package:flutter/material.dart';

class FintrackLogo extends StatelessWidget {
  const FintrackLogo({super.key, this.size = 160});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/fintracklogo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
