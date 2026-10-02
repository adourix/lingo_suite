import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_models.dart';
import '../../core/providers/auth_provider.dart';
import '../../features/suppliers/presentation/suppliers_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/products/presentation/products_page.dart';
import 'app_sidebar.dart';
import 'app_topbar.dart';
import '../../features/pos/presentation/pos_page.dart';
import '../../features/customers/presentation/customers_page.dart';
import '../../features/reports/presentation/reports_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int selectedIndex = 0;

  final List<String> titles = const [
    'Dashboard',
    'POS',
    'Products',
    'Customers',
    'Suppliers',
    'Reports',
  ];

  late final List<Widget> pages = [
    DashboardPage(onNewSale: () {
      if (Permissions.can(
        ref.read(authUserProvider)!.role,
        Permissions.pos,
      )) {
        setState(() => selectedIndex = 1);
      }
    }),
    const PosPage(),
    const ProductsPage(),
    const CustomersPage(),
    const SuppliersPage(),
    const ReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);
    if (user == null) return const SizedBox.shrink();

    bool can(String permission) =>
        Permissions.can(user.role, permission);

    if (!can(_permissionForIndex(selectedIndex))) {
      selectedIndex = _firstAllowedIndex(user.role);
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            AppSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                if (can(_permissionForIndex(index))) {
                  setState(() => selectedIndex = index);
                }
              },
              fullName: user.fullName,
              role: user.role,
              can: can,
              onLogout: () async {
                await ref.read(authRepositoryProvider).logout(user);
                ref.read(authUserProvider.notifier).state = null;
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

  String _permissionForIndex(int index) {
    switch (index) {
      case 0:
        return Permissions.dashboard;
      case 1:
        return Permissions.pos;
      case 2:
        return Permissions.products;
      case 3:
        return Permissions.customers;
      case 4:
        return Permissions.suppliers;
      case 5:
        return Permissions.reports;
      default:
        return '';
    }
  }

  int _firstAllowedIndex(String role) {
    for (var i = 0; i < titles.length; i++) {
      if (Permissions.can(role, _permissionForIndex(i))) return i;
    }
    return 0;
  }
}
