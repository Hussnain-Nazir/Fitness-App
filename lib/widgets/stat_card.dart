// stat_card.dart
// Small metric card - icon, value, label. Used on Home and Progress.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'vexon_card.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return VexonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: AppTextStyles.stat(color: AppColors.textPrimaryDark)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.statLabel(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
