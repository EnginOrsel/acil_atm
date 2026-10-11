import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/utils/bank_theme_helper.dart';

/// Firestore tabanlı ATM önbellek servisi.
/// Koordinat gridine göre (3 ondalık ≈ ~111m hassasiyet) önbellek yapar.
/// TTL: 14 gün
class FirestoreCacheService {
  static const int _cacheDays = 14;
  static final _firestore = FirebaseFirestore.instance;
  static const String _collection = 'cached_atms';

  /// Koordinat çiftinden grid anahtarı oluşturur (3 ondalık).
  static String _gridKey(double lat, double lng) {
    final latKey = lat.toStringAsFixed(3);
    final lngKey = lng.toStringAsFixed(3);
    return '${latKey}_$lngKey';
  }

  /// Önbellekten ATM listesini okur.
  /// Veri yoksa veya 14 günden eskiyse null döner.
  static Future<List<AtmPlace>?> getCachedAtms(double lat, double lng) async {
    try {
      final docId = _gridKey(lat, lng);
      final doc = await _firestore.collection(_collection).doc(docId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final cachedAt = (data['cachedAt'] as Timestamp?)?.toDate();

      // TTL kontrolü
      if (cachedAt == null) return null;
      final age = DateTime.now().difference(cachedAt);
      if (age.inDays >= _cacheDays) {
        debugPrint('Önbellek süresi dolmuş ($docId). Google API kullanılacak.');
        return null;
      }

      // ATM listesini çöz
      final atmListData = data['atms'] as List<dynamic>?;
      if (atmListData == null || atmListData.isEmpty) return null;

      final atms = atmListData
          .map((item) => AtmPlace.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      debugPrint('Önbellekten ${atms.length} ATM yüklendi ($docId).');
      return atms;
    } catch (e) {
      debugPrint('Önbellek okuma hatası: $e');
      return null;
    }
  }

  /// ATM listesini Firestore önbelleğine yazar.
  /// Her ATM'ye bankId ve bankColor hex değeri eklenir.
  static Future<void> cacheAtms(
    double lat,
    double lng,
    List<AtmPlace> atms,
  ) async {
    try {
      final docId = _gridKey(lat, lng);

      final atmListData = atms.map((atm) {
        final json = atm.toJson();
        // bankId yoksa çöz ve ekle
        if (json['bankId'] == null || (json['bankId'] as String).isEmpty) {
          json['bankId'] = BankThemeHelper.resolveBankKey(atm.name) ?? '';
        }
        // bankColor hex değerini kaydet
        json['bankColorHex'] = atm.bankColor.value.toRadixString(16).padLeft(8, '0');
        return json;
      }).toList();

      await _firestore.collection(_collection).doc(docId).set({
        'lat': lat,
        'lng': lng,
        'cachedAt': FieldValue.serverTimestamp(),
        'atmCount': atms.length,
        'atms': atmListData,
      });

      debugPrint('${atms.length} ATM önbelleğe yazıldı ($docId).');
    } catch (e) {
      debugPrint('Önbellek yazma hatası: $e');
      // Yazma hatası kritik değil, uygulama çalışmaya devam eder
    }
  }
}
