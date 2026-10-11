// 📁 lib/widgets/atm_card/_distance_badge.dart

import 'package:flutter/material.dart';

class DistanceBadge extends StatelessWidget {
  final int distance;

  const DistanceBadge({super.key, required this.distance});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 16, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            "$distance m",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
