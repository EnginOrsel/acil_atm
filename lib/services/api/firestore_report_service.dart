import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:acil_atm/models/atm_place.dart';

class FirestoreReportService {
  static final _firestore = FirebaseFirestore.instance;
  static const String _collection = 'atm_reports';

  // ─── Mevcut: ATM'yi raporlarla zenginleştir ───

  static Future<AtmPlace> enrichWithReports(AtmPlace atm) async {
    final now = DateTime.now();
    final sixHoursAgo = now.subtract(const Duration(hours: 6));

    final snapshot = await _firestore
        .collection(_collection)
        .where('atmId', isEqualTo: atm.id)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(sixHoursAgo))
        .get();

    final reportDetails = <String>[];
    for (var doc in snapshot.docs) {
      final issueType = doc.data()['issueType'] as String?;
      if (issueType != null) {
        reportDetails.add(issueType);
      }
      // Eski format desteği (reportedProblems listesi)
      final problems = doc.data()['reportedProblems'] as List<dynamic>?;
      if (problems != null) {
        reportDetails.addAll(problems.map((e) => e.toString()));
      }
    }

    return AtmPlace(
      id: atm.id,
      name: atm.name,
      bankId: atm.bankId,
      lat: atm.lat,
      lng: atm.lng,
      address: atm.address,
      lastReportedProblem: reportDetails.isNotEmpty ? reportDetails.last : null,
      directedUserCount: atm.directedUserCount,
      reportCount: reportDetails.length,
      reportDetails: reportDetails,
    );
  }

  // ─── Yeni: Sorun bildir ───

  /// Kullanıcının seçtiği sorunu Firestore'a yazar.
  ///
  /// [atmId] — Bildirim yapılan ATM'nin ID'si
  /// [issueType] — Sorun türü: 'no_cash', 'out_of_order', 'long_queue',
  ///               'card_reader_broken', 'screen_broken', 'other'
  static Future<void> submitReport(String atmId, String issueType) async {
    try {
      await _firestore.collection(_collection).add({
        'atmId': atmId,
        'issueType': issueType,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ [Report] Bildirim gönderildi: atmId=$atmId, issueType=$issueType');
    } catch (e) {
      debugPrint('❌ [Report] Bildirim gönderilemedi: $e');
      rethrow;
    }
  }

  // ─── Yeni: Aktif bildirimleri dinle (Stream) ───

  /// Belirli bir ATM için son 3 saat içindeki aktif bildirimleri
  /// gerçek zamanlı olarak dinler.
  ///
  /// Dönen stream, her güncellenmede sorun türlerinin listesini verir.
  /// 3 saatten eski bildirimler otomatik olarak filtrelenir.
  static Stream<List<String>> getActiveReports(String atmId) {
    final threeHoursAgo = DateTime.now().subtract(const Duration(hours: 3));

    return _firestore
        .collection(_collection)
        .where('atmId', isEqualTo: atmId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(threeHoursAgo))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final issues = <String>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Sunucu zamanı henüz yazılmamış olabilir (pending write)
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final docTime = timestamp.toDate();
          // İstemci tarafında da 3 saat kontrolü (stream canlı olduğu için)
          if (docTime.isAfter(DateTime.now().subtract(const Duration(hours: 3)))) {
            final issueType = data['issueType'] as String?;
            if (issueType != null) {
              issues.add(issueType);
            }
          }
        }
      }
      return issues;
    });
  }

  // ─── Yardımcı: Sorun türü etiketleri ───

  /// issueType kodundan kullanıcı dostu Türkçe etiket döndürür.
  static String getIssueLabel(String issueType) {
    switch (issueType) {
      case 'no_cash':
        return 'Para yok';
      case 'out_of_order':
        return 'Arızalı';
      case 'long_queue':
        return 'Uzun kuyruk';
      case 'card_reader_broken':
        return 'Kart okuyucu bozuk';
      case 'screen_broken':
        return 'Ekran bozuk';
      case 'other':
        return 'Diğer';
      default:
        return issueType;
    }
  }

  /// Mevcut tüm sorun türleri (UI'da seçim listesi için)
  static const List<Map<String, String>> issueTypes = [
    {'id': 'no_cash', 'label': 'Para yok', 'icon': '💸'},
    {'id': 'out_of_order', 'label': 'Arızalı', 'icon': '🔧'},
    {'id': 'long_queue', 'label': 'Uzun kuyruk', 'icon': '🚶‍♂️'},
    {'id': 'card_reader_broken', 'label': 'Kart okuyucu bozuk', 'icon': '💳'},
    {'id': 'screen_broken', 'label': 'Ekran bozuk', 'icon': '🖥️'},
    {'id': 'other', 'label': 'Diğer', 'icon': '❓'},
  ];
}