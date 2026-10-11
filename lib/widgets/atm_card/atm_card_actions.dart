// 📁 lib/widgets/atm_card/atm_card_actions.dart

import 'package:flutter/material.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/widgets/atm_card/_distance_badge.dart';
import 'package:acil_atm/widgets/atm_card/_report_warning.dart';
import 'package:acil_atm/widgets/atm_card/_action_buttons.dart';

class AtmCardActions extends StatelessWidget {
  final AtmPlace atmPlace;
  final double userLat;
  final double userLng;

  const AtmCardActions({
    super.key,
    required this.atmPlace,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    final distance = atmPlace.calculateDistance(userLat, userLng).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DistanceBadge(distance: distance),
            if (atmPlace.reportCount > 0)
              ReportWarning(atmPlace: atmPlace),
          ],
        ),
        const SizedBox(height: 12),
        ActionButtons(atmPlace: atmPlace),
      ],
    );
  }
}
