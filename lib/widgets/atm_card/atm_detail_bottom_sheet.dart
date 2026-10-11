import 'package:flutter/material.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/utils/bank_theme_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:acil_atm/widgets/report/report_problem_sheet.dart';

void showAtmDetailsBottomSheet(BuildContext context, AtmPlace atm, int distance) {
  final bankColor = atm.bankColor;
  final textOnBank = BankThemeHelper.getTextColorOnBank(atm.name);

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tutma çubuğu
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Renkli header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: bankColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: textOnBank, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atm.name,
                        style: TextStyle(
                          color: textOnBank,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ATM',
                        style: TextStyle(
                          color: textOnBank.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: textOnBank.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${distance}m',
                    style: TextStyle(
                      color: textOnBank,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detay listesi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(atm.address ?? ''),
                  subtitle: Text('Uzaklık: $distance metre'),
                ),
                if (atm.directedUserCount > 0)
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: Text("Son 6 saatte ${atm.directedUserCount} kişi bu ATM'ye yönlendirildi"),
                  ),
                if (atm.lastReportedProblem != null)
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: Text('Kullanıcı bildirimi: ${atm.lastReportedProblem}'),
                  ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.map_outlined, color: bankColor),
                  title: const Text('Haritada Göster'),
                  onTap: () {
                    final url = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${atm.lat},${atm.lng}',
                    );
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
                // ⚠️ Sorun Bildir butonu
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => ReportProblemSheet(atmPlace: atm),
                        );
                      },
                      icon: const Text('⚠️', style: TextStyle(fontSize: 18)),
                      label: const Text(
                        'Sorun Bildir',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        backgroundColor: Colors.red.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    },
  );
}
