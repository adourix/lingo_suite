import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget {
  final String title;

  const AppTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffe5e7eb))),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          SizedBox(
            width: 280,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: const Color(0xfff8fafc),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),

          const SizedBox(width: 10),

          const CircleAvatar(radius: 18, child: Icon(Icons.person)),
        ],
      ),
    );
  }
}
