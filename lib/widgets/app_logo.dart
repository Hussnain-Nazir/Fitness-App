// app_logo.dart
// Renders the Vexon logo consistently. Used on the splash screen (large),
// app bars (small), and auth screens (medium). Never stretched - always
// wrapped in a fixed square box that preserves aspect ratio.

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'public/assets/LOGO.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (!showBackground) return logo;

    return Container(
      width: size + 16,
      height: size + 16,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((size + 16) * 0.28),
      ),
      child: logo,
    );
  }
}
