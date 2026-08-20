// achievement_badge.dart
// Visual badges for the gamification system. Unlocked state is computed
// from existing streak/completed-workout data (see Achievement model) -
// nothing new is persisted.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/achievement.dart';
import 'vexon_card.dart';

/// Compact horizontal strip of badges - used on the Home dashboard.
class AchievementStrip extends StatelessWidget {
  final int streak;
  final int completedCount;

  const AchievementStrip({
    super.key,
    required this.streak,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kAchievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final achievement = kAchievements[i];
          final unlocked = achievement.isUnlocked(streak, completedCount);
          return _BadgeChip(achievement: achievement, unlocked: unlocked);
        },
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _BadgeChip({required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: unlocked ? null : Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            size: 24,
            color: unlocked ? AppColors.primaryBlue : AppColors.textSecondary,
          ),
          const SizedBox(height: 6),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall(
              color: unlocked ? AppColors.textPrimaryDark : AppColors.textSecondary,
            ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Full-width list tile with description - used on the Profile screen.
class AchievementList extends StatelessWidget {
  final int streak;
  final int completedCount;

  const AchievementList({
    super.key,
    required this.streak,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: kAchievements.map((achievement) {
        final unlocked = achievement.isUnlocked(streak, completedCount);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: VexonCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? AppColors.primaryBlue
                        : AppColors.cardBorderLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: unlocked ? Colors.white : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(achievement.title,
                          style: AppTextStyles.heading3(
                              color: AppColors.textPrimaryDark)),
                      Text(achievement.description, style: AppTextStyles.bodySmall()),
                    ],
                  ),
                ),
                Icon(
                  unlocked ? Icons.check_circle : Icons.lock_outline,
                  color: unlocked ? AppColors.success : AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
