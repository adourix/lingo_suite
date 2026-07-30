import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

import '../../../core/providers/analytics_provider.dart';

import 'widgets/recent_orders.dart';
import 'widgets/sales_chart.dart';
import 'widgets/stat_card.dart';
import 'widgets/top_products.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(totalSalesProvider);

    final orders = ref.watch(totalOrdersProvider);

    final customers = ref.watch(totalCustomersProvider);

    final products = ref.watch(totalProductsProvider);

    return SingleChildScrollView(
      padding: AppSpacing.page,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text("Dashboard", style: AppTextStyles.h1),

          const SizedBox(height: 8),

          LayoutBuilder(
            builder: (context, constraints) {
              int count = 4;

              if (constraints.maxWidth < 1000) {
                count = 2;
              }

              if (constraints.maxWidth < 600) {
                count = 1;
              }

              return GridView.count(
                crossAxisCount: count,

                crossAxisSpacing: 24,

                mainAxisSpacing: 24,

                childAspectRatio: 1.5,

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                children: [
                  StatCard(
                    title: "Sales",

                    value: _doubleValue(sales),

                    change: "Current Period",

                    icon: Icons.attach_money,
                  ),

                  StatCard(
                    title: "Orders",

                    value: _intValue(orders),

                    change: "Total",

                    icon: Icons.shopping_cart_outlined,
                  ),

                  StatCard(
                    title: "Customers",

                    value: _intValue(customers),

                    change: "Registered",

                    icon: Icons.people_outline,
                  ),

                  StatCard(
                    title: "Products",

                    value: _intValue(products),

                    change: "Active",

                    icon: Icons.inventory_2_outlined,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Expanded(flex: 2, child: SalesChart()),

                    const SizedBox(width: 24),

                    const Expanded(child: RecentOrders()),
                  ],
                );
              }

              return const Column(
                children: [SalesChart(), SizedBox(height: 24), RecentOrders()],
              );
            },
          ),

          const SizedBox(height: 32),

          const TopProducts(),
        ],
      ),
    );
  }

  String _doubleValue(AsyncValue<double> value) {
    return value.when(
      data: (v) => "${v.toStringAsFixed(0)} EGP",

      loading: () => "...",

      error: (_, _) => "0",
    );
  }

  String _intValue(AsyncValue<int> value) {
    return value.when(
      data: (v) => v.toString(),

      loading: () => "...",

      error: (_, _) => "0",
    );
  }
}
