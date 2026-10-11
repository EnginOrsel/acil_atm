import 'package:flutter/material.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/utils/bank_theme_helper.dart';
import 'atm_card_actions.dart';
import 'package:acil_atm/widgets/atm_card/atm_detail_bottom_sheet.dart';

class AtmInfoCard extends StatelessWidget {
  final AtmPlace atmPlace;
  final double userLat;
  final double userLng;

  const AtmInfoCard({
    Key? key,
    required this.atmPlace,
    required this.userLat,
    required this.userLng,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distance = atmPlace.calculateDistance(userLat, userLng).round();
    final bankColor = atmPlace.bankColor;
    final textOnBank = BankThemeHelper.getTextColorOnBank(atmPlace.name);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => showAtmDetailsBottomSheet(context, atmPlace, distance),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: bankColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Renkli üst bant (header)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bankColor,
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance, color: textOnBank, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      atmPlace.name,
                      style: textTheme.titleSmall?.copyWith(
                        color: textOnBank,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: textOnBank.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${distance}m',
                      style: TextStyle(
                        color: textOnBank,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Alt bilgi alanı
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          atmPlace.address ?? '',
                          style: textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AtmCardActions(atmPlace: atmPlace, userLat: userLat, userLng: userLng),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
