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
  children: [
    Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const Spacer(),
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: isPositive ? AppColors.success : AppColors.danger,
          size: 20,
        ),
      ],
    ),

    const SizedBox(height: 20),

    Text(
      title,
      style: AppTextStyles.bodySmall,
    ),

    const SizedBox(height: 10),

    Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.h2.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(height: 8),

    Text(
      change,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isPositive ? AppColors.success : AppColors.danger,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
),
    );
  }
}