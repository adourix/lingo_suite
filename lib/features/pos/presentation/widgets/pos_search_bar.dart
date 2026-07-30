import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/pos_search_provider.dart';

class PosSearchBar extends ConsumerWidget {
  const PosSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Search product or scan barcode...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.qr_code_scanner),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onChanged: (value) {
              ref.read(posSearchQueryProvider.notifier).state = value;
            },
          ),
        ),

        const SizedBox(width: AppSpacing.lg),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Row(
            children: [
              Icon(Icons.receipt_long_outlined),
              SizedBox(width: 8),
              Text(
                "Invoice #1001",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Row(
            children: [
              CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
              SizedBox(width: 8),
              Text("Admin"),
            ],
          ),
        ),
      ],
    );
  }
}
