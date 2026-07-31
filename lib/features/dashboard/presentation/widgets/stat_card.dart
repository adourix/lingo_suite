import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    this.isPositive = true,
  });

  final String title;
  final String value;
  final String change;
  final IconData icon;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(AppRadius.lg),

        border: Border.all(color: AppColors.border),

        boxShadow: AppShadows.card,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        mainAxisSize: MainAxisSize.min,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),

                decoration: BoxDecoration(
                  color: AppColors.primaryLight,

                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),

                child: Icon(icon, color: AppColors.primary, size: 22),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,

                      size: 16,

                      color: isPositive ? AppColors.success : AppColors.danger,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      change,

                      style: AppTextStyles.bodySmall.copyWith(
                        color: isPositive
                            ? AppColors.success
                            : AppColors.danger,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(title, style: AppTextStyles.bodySmall),

          const SizedBox(height: 6),

          Text(
            value,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
