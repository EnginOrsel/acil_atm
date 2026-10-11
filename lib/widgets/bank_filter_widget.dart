import 'package:flutter/material.dart';
import 'package:acil_atm/utils/bank_theme_helper.dart';

class BankFilterDropdown extends StatelessWidget {
  final List<String> bankNames;
  final String selectedBank;
  final ValueChanged<String> onChanged;

  const BankFilterDropdown({
    super.key,
    required this.bankNames,
    required this.selectedBank,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> allBankNames = ['Tüm Bankalar', ...bankNames];

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedBank.isEmpty ? 'Tüm Bankalar' : selectedBank,
          isExpanded: true,
          items: allBankNames.map((bank) {
            final isAll = bank == 'Tüm Bankalar';
            final bankColor = isAll
                ? Colors.grey
                : BankThemeHelper.getBankColor(bank);
            final bankInitials = isAll
                ? '∀'
                : BankThemeHelper.getBankInitials(bank);
            final textColor = isAll
                ? Colors.white
                : BankThemeHelper.getTextColorOnBank(bank);

            return DropdownMenuItem(
              value: bank,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: bankColor,
                    radius: 14,
                    child: Text(
                      bankInitials,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(bank),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value == 'Tüm Bankalar' ? '' : value);
            }
          },
        ),
      ),
    );
  }
}
