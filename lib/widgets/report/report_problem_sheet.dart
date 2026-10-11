import 'package:flutter/material.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/services/api/firestore_report_service.dart';

class ReportProblemSheet extends StatefulWidget {
  final AtmPlace atmPlace;

  const ReportProblemSheet({Key? key, required this.atmPlace}) : super(key: key);

  @override
  State<ReportProblemSheet> createState() => _ReportProblemSheetState();
}

class _ReportProblemSheetState extends State<ReportProblemSheet> {
  String? _selectedIssue;
  bool _isSubmitting = false;

  static const List<_IssueOption> _options = [
    _IssueOption(id: 'no_cash', label: 'Para Bitmiş', emoji: '💸'),
    _IssueOption(id: 'out_of_order', label: 'ATM Arızalı', emoji: '🛠️'),
    _IssueOption(id: 'long_queue', label: 'Sıra Çok Uzun', emoji: '🚶‍♂️'),
  ];

  Future<void> _submit() async {
    if (_selectedIssue == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await FirestoreReportService.submitReport(
        widget.atmPlace.id,
        _selectedIssue!,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bildiriminiz için teşekkürler! 🎉'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bildirim gönderilemedi. Tekrar deneyin.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tutma çubuğu
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Başlık
          Row(
            children: [
              Icon(Icons.report_outlined, color: colorScheme.error, size: 24),
              const SizedBox(width: 10),
              Text(
                'Sorun Bildir',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ATM adı
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.atmPlace.name,
              style: textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          // Seçenekler
          ...List.generate(_options.length, (index) {
            final option = _options[index];
            final isSelected = _selectedIssue == option.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _selectedIssue = option.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        width: isSelected ? 2 : 1.5,
                      ),
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Text(option.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            option.label,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? colorScheme.primary : null,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: colorScheme.primary, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Gönder butonu
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _selectedIssue == null || _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _isSubmitting ? 'Gönderiliyor...' : 'Bildir',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueOption {
  final String id;
  final String label;
  final String emoji;

  const _IssueOption({
    required this.id,
    required this.label,
    required this.emoji,
  });
}
