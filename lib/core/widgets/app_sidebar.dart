import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
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
            "Lingo Store",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          _item(0, Icons.dashboard_outlined, "Dashboard"),
          _item(1, Icons.point_of_sale_outlined, "POS"),
          _item(2, Icons.inventory_2_outlined, "Products"),

          _item(3, Icons.people_outline, "Customers"),
          _item(4, Icons.local_shipping_outlined, "Suppliers"),
          _item(5, Icons.bar_chart_outlined, "Reports"),

          const Spacer(),

          const Divider(),

          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Admin"),
            subtitle: Text("Administrator"),
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
