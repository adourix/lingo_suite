import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final String fullName;
  final String role;
  final VoidCallback onLogout;
  final bool Function(String permission) can;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.fullName,
    required this.role,
    required this.onLogout,
    required this.can,
  });

  @override
  Widget build(BuildContext context) {
    final items = <({int index, IconData icon, String title, String permission})>[
      (index: 0, icon: Icons.dashboard_outlined, title: 'Dashboard', permission: 'dashboard'),
      (index: 1, icon: Icons.point_of_sale_outlined, title: 'POS', permission: 'pos'),
      (index: 2, icon: Icons.inventory_2_outlined, title: 'Products', permission: 'products'),
      (index: 3, icon: Icons.people_outline, title: 'Customers', permission: 'customers'),
      (index: 4, icon: Icons.local_shipping_outlined, title: 'Suppliers', permission: 'suppliers'),
      (index: 5, icon: Icons.bar_chart_outlined, title: 'Reports', permission: 'reports'),
      (index: 6, icon: Icons.history, title: 'Audit Log', permission: 'auditLogs'),
      (index: 7, icon: Icons.manage_accounts_outlined, title: 'Users', permission: 'manageUsers'),
    ];

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xffe5e7eb))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 25),
          const Text(
            'Lingo Store',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          for (final item in items)
            if (can(item.permission))
              _item(item.index, item.icon, item.title),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(fullName),
            subtitle: Text(role.toUpperCase()),
            trailing: IconButton(
              tooltip: 'Logout',
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _item(int index, IconData icon, String title) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        selected: selected,
        selectedTileColor: const Color(0xffeff6ff),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: selected ? Colors.blue : Colors.black87),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}
