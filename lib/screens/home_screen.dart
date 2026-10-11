import 'package:flutter/material.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/services/session_data.dart';
import 'package:acil_atm/widgets/atm_card/atm_info_card.dart';
import 'package:acil_atm/widgets/bank_filter_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AtmPlace> allAtms = [];
  List<AtmPlace> filteredAtms = [];
  bool isLoading = true;
  String selectedBank = '';

  final Map<String, List<String>> supportedBankKeywords = {
    'Ziraat': ['ziraat'],
    'VakıfBank': ['vakıf', 'vakif'],
    'Halkbank': ['halk'],
    'İş Bankası': ['iş', 'is ', 'isbank', 'işbank', 'bankamatik'],
    'Garanti BBVA': ['garanti'],
    'QNB Finansbank': ['qnb', 'finansbank'],
    'Yapı Kredi': ['yapı', 'kredi', 'yapi', 'yapıkredi'],
    'Akbank': ['akbank'],
    'ING': ['ing'],
    'TEB': ['teb', 'ekonomi'],
    'DenizBank': ['deniz'],
    'Kuveyt Türk': ['kuveyt'],
    'Albaraka': ['albaraka'],
    'Şekerbank': ['şeker', 'seker'],
    'HSBC': ['hsbc']
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await SessionData().initialize();
      allAtms = SessionData().atmList;
      filteredAtms = _filterAtms(selectedBank);
    } catch (e) {
      debugPrint('Hata: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<AtmPlace> _filterAtms(String bank) {
    if (bank.isEmpty) {
      return allAtms.where((atm) => _matchesAnySupportedBank(atm.name)).toList();
    }
    return allAtms.where((atm) => SessionData.normalizeBankName(atm.name) == bank).toList();
  }

  bool _matchesAnySupportedBank(String name) {
    final lowerName = name.toLowerCase();
    return supportedBankKeywords.values.any((keywords) => keywords.any((keyword) => lowerName.contains(keyword)));
  }

  List<String> _extractBankNames() {
    final bankSet = <String>{};

    for (var atm in allAtms) {
      for (var entry in supportedBankKeywords.entries) {
        if (entry.value.any((kw) => atm.name.toLowerCase().contains(kw))) {
          bankSet.add(entry.key);
          break;
        }
      }
    }

    return bankSet.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (filteredAtms.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("ATM bulunamadı.")),
      );
    }

    final currentPosition = SessionData().userPosition;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acil ATM'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: BankFilterDropdown(
              bankNames: _extractBankNames(),
              selectedBank: selectedBank,
              onChanged: (bank) {
                setState(() {
                  selectedBank = bank;
                  filteredAtms = _filterAtms(bank);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredAtms.length,
              itemBuilder: (context, index) {
                final atm = filteredAtms[index];
                return AtmInfoCard(
                  atmPlace: atm,
                  userLat: currentPosition.latitude,
                  userLng: currentPosition.longitude,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
