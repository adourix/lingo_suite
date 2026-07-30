import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../../../core/providers/analytics_provider.dart';

class SalesChart extends ConsumerWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = ref.watch(salesChartProvider);

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
          Text('Sales Overview', style: AppTextStyles.h3),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            height: 300,

            child: chart.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text("No Sales Data"));
                }

                final spots = data.asMap().entries.map((e) {
                  return FlSpot(
                    e.key.toDouble(),

                    (e.value["total"] as num).toDouble(),
                  );
                }).toList();

                return LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),

                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),

                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),

                      rightTitles: const AxisTitles(),

                      leftTitles: const AxisTitles(),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,

                          reservedSize: 28,

                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= data.length) {
                              return const SizedBox();
                            }

                            final day = data[value.toInt()]["day"].toString();

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),

                              child: Text(
                                day.length > 5 ? day.substring(5) : day,

                                style: AppTextStyles.caption,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    minX: 0,

                    maxX: spots.length.toDouble() - 1,

                    minY: 0,

                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,

                        isCurved: true,

                        color: AppColors.primary,

                        barWidth: 4,

                        isStrokeCapRound: true,

                        dotData: const FlDotData(show: false),

                        belowBarData: BarAreaData(
                          show: true,

                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                );
              },

              loading: () => const Center(child: CircularProgressIndicator()),

              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}
