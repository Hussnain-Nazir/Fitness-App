// page_transitions.dart
// Lightweight fade + slide transition used for primary navigation flows.
// Keeps transitions fast (180ms) and subtle per the micro-interactions
// guidance - this is a drop-in replacement for MaterialPageRoute.

import 'package:flutter/material.dart';

class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeSlideRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Convenience: `Navigator.of(context).push(vexonRoute(const MyScreen()))`
Route<T> vexonRoute<T>(Widget page) => FadeSlideRoute<T>(page: page);
