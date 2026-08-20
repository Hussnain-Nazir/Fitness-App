// animated_progress.dart
// Thin wrappers around LinearProgressIndicator / CircularProgressIndicator
// that animate value changes instead of snapping instantly - used for the
// mission bar (Home) and the calorie ring (Progress).

import 'package:flutter/material.dart';

class AnimatedLinearProgress extends StatelessWidget {
  final double value;
  final double minHeight;
  final Color backgroundColor;
  final Color valueColor;

  const AnimatedLinearProgress({
    super.key,
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
    this.minHeight = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return LinearProgressIndicator(
          value: animatedValue,
          minHeight: minHeight,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation(valueColor),
        );
      },
    );
  }
}

class AnimatedProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color valueColor;
  final Widget Function(double animatedValue) centerBuilder;

  const AnimatedProgressRing({
    super.key,
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
    required this.centerBuilder,
    this.size = 90,
    this.strokeWidth = 9,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: animatedValue,
                  strokeWidth: strokeWidth,
                  backgroundColor: backgroundColor,
                  valueColor: AlwaysStoppedAnimation(valueColor),
                ),
              ),
              centerBuilder(animatedValue),
            ],
          ),
        );
      },
    );
  }
}
