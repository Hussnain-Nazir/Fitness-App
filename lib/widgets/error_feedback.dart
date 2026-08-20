// error_feedback.dart
// Shared, reusable widgets/functions for displaying validation errors
// (used by both the Signup and Login screens).

import 'package:flutter/material.dart';

const Color kErrorRed = Color(0xFFE53935);

/// Small inline error banner shown near the top of a form.
class InlineFormError extends StatelessWidget {
  final String message;
  const InlineFormError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kErrorRed.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: kErrorRed, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: kErrorRed, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating error snackbar, callable from anywhere with a BuildContext.
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kErrorRed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
    ),
  );
}
