import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/widgets/report/report_problem_sheet.dart';

class ActionButtons extends StatelessWidget {
  final AtmPlace atmPlace;

  const ActionButtons({
    Key? key,
    required this.atmPlace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _launchMap(atmPlace.lat, atmPlace.lng),
          icon: Icon(Icons.map_outlined, color: colorScheme.primary),
          label: Text(
            "Haritada Göster",
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => _showProblemReportBottomSheet(context),
          icon: const Icon(Icons.report_problem_outlined, color: Colors.red),
          label: const Text(
            "Sorun Bildir",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  void _launchMap(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showProblemReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReportProblemSheet(atmPlace: atmPlace),
    );
  }
}
