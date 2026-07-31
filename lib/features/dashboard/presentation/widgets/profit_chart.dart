import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/providers/analytics_provider.dart';

class ProfitChart extends ConsumerWidget {
  const ProfitChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = ref.watch(dashboardProfitChartProvider);
    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),

        boxShadow: AppShadows.card,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text("Profit Overview", style: AppTextStyles.h3),

          const SizedBox(height: 4),

          Text("Last 7 days performance", style: AppTextStyles.bodySmall),

          const SizedBox(height: 28),

          SizedBox(
            height: 300,

            child: chart.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (e, _) => Center(child: Text(e.toString())),

              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text("No Data"));
                }

                final sales = data.asMap().entries.map((e) {
                  return FlSpot(
                    e.key.toDouble(),

                    (e.value["sales"] as num).toDouble(),
                  );
                }).toList();

                final profit = data.asMap().entries.map((e) {
                  return FlSpot(
                    e.key.toDouble(),

                    (e.value["profit"] as num).toDouble(),
                  );
                }).toList();

                return LineChart(
                  LineChartData(
                    minY: 0,
                    minX: 0,
                    maxX: (data.length - 1).toDouble(),
                    borderData: FlBorderData(show: false),

                    gridData: FlGridData(show: true, drawVerticalLine: false),

                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),

                      rightTitles: const AxisTitles(),

                      leftTitles: const AxisTitles(),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,

                          interval: 1,

                          reservedSize: 40,

                          getTitlesWidget: (value, meta) {
                            final index = value.round();

                            if (index < 0 || index >= data.length) {
                              return const SizedBox();
                            }

                            final day = data[index]["day"]?.toString() ?? "";

                            return SideTitleWidget(
                              meta: meta,

                              child: Text(
                                day.length >= 10 ? day.substring(5) : day,

                                style: AppTextStyles.caption,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            final title = spot.barIndex == 0
                                ? "Sales"
                                : "Profit";

                            return LineTooltipItem(
                              "$title\n${spot.y.toStringAsFixed(0)} EGP",

                              const TextStyle(fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: sales,

                        isCurved: true,

                        color: AppColors.primary,

                        barWidth: 4,

                        isStrokeCapRound: true,

                        dotData: const FlDotData(show: true),
                      ),

                      LineChartBarData(
                        spots: profit,

                        isCurved: true,

                        color: AppColors.primary,

                        barWidth: 4,

                        isStrokeCapRound: true,

                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
