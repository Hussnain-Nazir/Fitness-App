// empty_state.dart
// Consistent placeholder for screens with no data yet: icon, short
// guidance text, and an optional call-to-action.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(icon, color: AppColors.accentBlue, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.heading3(), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: PrimaryButton(label: actionLabel!, onPressed: onAction),
            ),
          ],
        ],
      ),
    );
  }
}
