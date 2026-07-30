import 'package:flutter/material.dart';
import '../../features/suppliers/presentation/suppliers_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/products/presentation/products_page.dart';
import 'app_sidebar.dart';
import 'app_topbar.dart';
import '../../features/pos/presentation/pos_page.dart';
import '../../features/customers/presentation/customers_page.dart';
import '../../features/reports/presentation/reports_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;
  final List<String> titles = [
    "Dashboard",
    "POS",
    "Products",
    "Customers",
    "Suppliers",
    "Reports",
  ];
  late final List<Widget> pages = [
    const DashboardPage(), // 0
    const PosPage(), // 1
    const ProductsPage(), // 2
    const CustomersPage(),
    const SuppliersPage(),
    const ReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            AppSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),

            Expanded(
              child: Column(
                children: [
                  AppTopBar(title: titles[selectedIndex]),

                  Expanded(child: pages[selectedIndex]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
