// primary_button.dart
// Shared primary action button with a subtle press animation.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool outlined;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.outlined = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  double _scale = 1.0;

  void _setScale(double value) {
    if (widget.onPressed == null || widget.loading) return;
    setState(() => _scale = value);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;

    return GestureDetector(
      onTapDown: (_) => _setScale(0.97),
      onTapUp: (_) => _setScale(1.0),
      onTapCancel: () => _setScale(1.0),
      onTap: disabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: widget.outlined
                ? Colors.transparent
                : (disabled && !widget.loading
                    ? AppColors.primaryBlue.withOpacity(0.5)
                    : AppColors.primaryBlue),
            border: widget.outlined
                ? Border.all(color: AppColors.primaryBlue, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon,
                            size: 18,
                            color: widget.outlined
                                ? AppColors.accentBlue
                                : Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: AppTextStyles.button(
                          color: widget.outlined
                              ? AppColors.accentBlue
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
