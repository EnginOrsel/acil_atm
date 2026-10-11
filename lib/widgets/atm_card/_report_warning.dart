import 'package:flutter/material.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/services/api/firestore_report_service.dart';

class ReportWarning extends StatelessWidget {
  final AtmPlace atmPlace;

  const ReportWarning({super.key, required this.atmPlace});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: FirestoreReportService.getActiveReports(atmPlace.id),
      builder: (context, snapshot) {
        // Veri yoksa veya boşsa gizle
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final issues = snapshot.data!;
        // En sık bildirilen sorunu bul
        final primaryIssue = _getMostFrequent(issues);
        final issueInfo = _getIssueDisplay(primaryIssue);
        final issueCount = issues.length;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: issueInfo.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: issueInfo.borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(issueInfo.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issueInfo.message,
                      style: TextStyle(
                        color: issueInfo.textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (issueCount > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Son 3 saatte $issueCount bildirim yapıldı',
                          style: TextStyle(
                            color: issueInfo.textColor.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Listede en çok tekrar eden sorun türünü döndürür
  String _getMostFrequent(List<String> issues) {
    final counts = <String, int>{};
    for (final issue in issues) {
      counts[issue] = (counts[issue] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Sorun türüne göre görsel bilgi döndürür
  _IssueDisplay _getIssueDisplay(String issueType) {
    switch (issueType) {
      case 'no_cash':
        return _IssueDisplay(
          emoji: '⚠️',
          message: "Bu ATM'de para bittiği bildirildi",
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          textColor: Colors.red.shade800,
        );
      case 'out_of_order':
        return _IssueDisplay(
          emoji: '⚠️',
          message: 'Bu ATM arızalı olabilir',
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          textColor: Colors.orange.shade900,
        );
      case 'long_queue':
        return _IssueDisplay(
          emoji: '🚶‍♂️',
          message: 'Bu ATM\'de uzun kuyruk bildirildi',
          backgroundColor: Colors.amber.shade50,
          borderColor: Colors.amber.shade200,
          textColor: Colors.amber.shade900,
        );
      case 'card_reader_broken':
        return _IssueDisplay(
          emoji: '💳',
          message: 'Kart okuyucu arızalı olabilir',
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          textColor: Colors.red.shade800,
        );
      case 'screen_broken':
        return _IssueDisplay(
          emoji: '🖥️',
          message: 'ATM ekranı arızalı olabilir',
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          textColor: Colors.orange.shade900,
        );
      default:
        return _IssueDisplay(
          emoji: '⚠️',
          message: 'Bu ATM hakkında sorun bildirildi',
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
          textColor: Colors.grey.shade800,
        );
    }
  }
}

class _IssueDisplay {
  final String emoji;
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _IssueDisplay({
    required this.emoji,
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
