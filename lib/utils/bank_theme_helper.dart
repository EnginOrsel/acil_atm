import 'package:flutter/material.dart';

/// Her banka için kurumsal renk haritası.
/// Anahtar: banka adını eşleştirmek için kullanılan küçük harf anahtar kelime.
class BankThemeHelper {
  BankThemeHelper._();

  /// Banka adı → kurumsal renk eşleştirmesi
  static const Map<String, Color> _bankColors = {
    'akbank': Color(0xFFE30613),       // Akbank Kırmızısı
    'albaraka': Color(0xFF00A651),     // Albaraka Yeşili
    'denizbank': Color(0xFF003DA5),    // DenizBank Laciverti
    'garanti': Color(0xFF009138),      // Garanti BBVA Yeşili
    'halkbank': Color(0xFF004B93),     // Halkbank Mavisi
    'hsbc': Color(0xFFDB0011),         // HSBC Kırmızısı
    'ing': Color(0xFFFF6200),          // ING Turuncusu
    'isbank': Color(0xFF003D88),       // İş Bankası Laciverti
    'kuveytturk': Color(0xFF00A94F),   // Kuveyt Türk Yeşili
    'qnb': Color(0xFF6F2C91),         // QNB Finansbank Moru
    'sekerbank': Color(0xFFFFCC00),    // Şekerbank Sarısı
    'teb': Color(0xFF0032A0),          // TEB Mavisi
    'vakifbank': Color(0xFFFFCC00),    // VakıfBank Sarısı
    'yapikredi': Color(0xFF004990),    // Yapı Kredi Mavisi
    'ziraat': Color(0xFFE21E26),       // Ziraat Bankası Kırmızısı
  };

  /// Banka adındaki anahtar kelimeleri eşleştirme kuralları
  static const Map<String, List<String>> _bankKeywords = {
    'akbank': ['akbank'],
    'albaraka': ['albaraka'],
    'denizbank': ['deniz'],
    'garanti': ['garanti'],
    'halkbank': ['halk'],
    'hsbc': ['hsbc'],
    'ing': ['ing'],
    'isbank': ['iş', 'is ', 'isbank', 'işbank', 'bankamatik'],
    'kuveytturk': ['kuveyt'],
    'qnb': ['qnb', 'finansbank'],
    'sekerbank': ['şeker', 'seker'],
    'teb': ['teb', 'ekonomi'],
    'vakifbank': ['vakıf', 'vakif'],
    'yapikredi': ['yapı', 'kredi', 'yapikredi', 'yapıkredi'],
    'ziraat': ['ziraat'],
  };

  /// Banka adının kısa gösterim metni (avatar içindeki harfler)
  static const Map<String, String> _bankInitials = {
    'akbank': 'AK',
    'albaraka': 'AL',
    'denizbank': 'DB',
    'garanti': 'GB',
    'halkbank': 'HB',
    'hsbc': 'HS',
    'ing': 'IN',
    'isbank': 'İŞ',
    'kuveytturk': 'KT',
    'qnb': 'QN',
    'sekerbank': 'ŞB',
    'teb': 'TE',
    'vakifbank': 'VB',
    'yapikredi': 'YK',
    'ziraat': 'ZB',
  };

  /// Banka ATM adından banka key'ini döndürür.
  static String? resolveBankKey(String bankName) {
    final name = bankName.toLowerCase();
    for (final entry in _bankKeywords.entries) {
      if (entry.value.any((kw) => name.contains(kw))) {
        return entry.key;
      }
    }
    return null;
  }

  /// Banka adından kurumsal rengini döndürür.
  static Color getBankColor(String bankName) {
    final key = resolveBankKey(bankName);
    if (key != null && _bankColors.containsKey(key)) {
      return _bankColors[key]!;
    }
    return const Color(0xFF9E9E9E); // Varsayılan gri
  }

  /// Banka adından kısa harf gösterimini döndürür.
  static String getBankInitials(String bankName) {
    final key = resolveBankKey(bankName);
    if (key != null && _bankInitials.containsKey(key)) {
      return _bankInitials[key]!;
    }
    return 'AT'; // Varsayılan: ATM
  }

  /// Renk açık mı kontrolü (metin rengini belirlemek için)
  static Color getTextColorOnBank(String bankName) {
    final color = getBankColor(bankName);
    return ThemeData.estimateBrightnessForColor(color) == Brightness.light
        ? Colors.black87
        : Colors.white;
  }
}
