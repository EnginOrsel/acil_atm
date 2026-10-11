import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:acil_atm/env/env.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/services/api/firestore_report_service.dart';
import 'package:acil_atm/services/api/firestore_cache_service.dart';

class GooglePlacesService {
  static const double maxDistanceMeters = 1500;

  /// ATM'leri getirir: önce Firestore önbelleğini kontrol eder,
  /// yoksa veya eskiyse Google API'ye gider ve sonuçları önbelleğe yazar.
  static Future<List<AtmPlace>> fetchNearbyAtms(double latitude, double longitude) async {
    debugPrint('══════════════════════════════════════════');
    debugPrint('📍 fetchNearbyAtms başlatıldı');
    debugPrint('   Koordinat: $latitude, $longitude');
    debugPrint('══════════════════════════════════════════');

    // ── 1. Önbellek kontrolü ──
    try {
      debugPrint('🔍 [1/4] Firestore önbellek kontrol ediliyor...');
      final cachedAtms = await FirestoreCacheService.getCachedAtms(latitude, longitude);

      if (cachedAtms != null && cachedAtms.isNotEmpty) {
        debugPrint('✅ [1/4] Önbellekten ${cachedAtms.length} ATM bulundu.');
        final enriched = await _enrichAndSort(cachedAtms, latitude, longitude);
        debugPrint('✅ Toplam ${enriched.length} ATM döndürülüyor (önbellekten).');
        return enriched;
      } else {
        debugPrint('⚠️ [1/4] Önbellek boş veya süresi dolmuş.');
      }
    } catch (e, stack) {
      debugPrint('❌ [1/4] Önbellek okuma hatası: $e');
      debugPrint('   Stack: $stack');
    }

    // ── 2. Google Places API'den çek ──
    debugPrint('🌐 [2/4] Google Places API sorgulanıyor...');
    List<AtmPlace> apiAtms;
    try {
      apiAtms = await _fetchFromGoogleApi(latitude, longitude);
      debugPrint('✅ [2/4] API\'den ${apiAtms.length} ATM çekildi.');
    } catch (e, stack) {
      debugPrint('❌ [2/4] Google API genel hata: $e');
      debugPrint('   Stack: $stack');
      return [];
    }

    if (apiAtms.isEmpty) {
      debugPrint('⚠️ [2/4] API sonucu BOŞ! ATM bulunamadı.');
      return [];
    }

    // ── 3. Raporlarla zenginleştir ──
    debugPrint('📊 [3/4] Raporlarla zenginleştirme...');
    List<AtmPlace> enriched;
    try {
      enriched = await _enrichAndSort(apiAtms, latitude, longitude);
      debugPrint('✅ [3/4] ${enriched.length} ATM zenginleştirildi ve sıralandı.');
    } catch (e, stack) {
      debugPrint('❌ [3/4] Zenginleştirme hatası: $e');
      debugPrint('   Stack: $stack');
      enriched = apiAtms; // Zenginleştirme başarısız olursa ham veriyi kullan
    }

    // ── 4. Sonuçları arka planda önbelleğe yaz ──
    debugPrint('💾 [4/4] Sonuçlar önbelleğe yazılıyor (fire-and-forget)...');
    FirestoreCacheService.cacheAtms(latitude, longitude, enriched);

    debugPrint('══════════════════════════════════════════');
    debugPrint('✅ Toplam ${enriched.length} ATM döndürülüyor.');
    debugPrint('══════════════════════════════════════════');
    return enriched;
  }

  /// Google Places API'den ham ATM verilerini çeker.
  static Future<List<AtmPlace>> _fetchFromGoogleApi(double latitude, double longitude) async {
    final apiKey = Env.googleMapsApiKey;

    // API key kontrolü
    if (apiKey.isEmpty) {
      debugPrint('❌ [API] GOOGLE_MAPS_API_KEY boş!');
      return [];
    }
    debugPrint('🔑 [API] API Key mevcut (şifreli, envied)');

    List<AtmPlace> atmResults = [];
    String? nextPageToken;
    int pageNumber = 0;
    const int maxPages = 3; // Maks 3 sayfa = 60 sonuç

    do {
      pageNumber++;
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$latitude,$longitude'
        '&radius=1500'
        '&type=atm'
        '&key=$apiKey'
        '${nextPageToken != null ? '&pagetoken=$nextPageToken' : ''}',
      );

      debugPrint('🌐 [API] Sayfa $pageNumber/$maxPages isteği gönderiliyor...');
      debugPrint('   URL: ${url.toString().replaceAll(apiKey, 'API_KEY_HIDDEN')}');

      // ── HTTP isteği ──
      http.Response response;
      try {
        response = await http.get(url);
      } catch (e, stack) {
        debugPrint('❌ [API] HTTP isteği başarısız (ağ hatası): $e');
        debugPrint('   Stack: $stack');
        break;
      }

      debugPrint('📡 [API] HTTP Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('❌ [API] HTTP hata! Status: ${response.statusCode}');
        debugPrint('   Response body: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
        break;
      }

      // ── JSON parse ──
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        debugPrint('❌ [API] JSON parse hatası: $e');
        debugPrint('   Body (ilk 500 karakter): ${response.body.substring(0, response.body.length.clamp(0, 500))}');
        break;
      }

      // API seviye hata kontrolü
      final status = data['status'];
      debugPrint('📋 [API] Google API status: $status');

      if (status != 'OK' && status != 'ZERO_RESULTS') {
        debugPrint('❌ [API] Google API hatası!');
        debugPrint('   status: $status');
        debugPrint('   error_message: ${data['error_message'] ?? 'yok'}');
        break;
      }

      if (status == 'ZERO_RESULTS') {
        debugPrint('⚠️ [API] Google ZERO_RESULTS döndü — bu koordinatta ATM yok.');
        break;
      }

      // ── Sonuçları parse et ──
      final results = data['results'] as List<dynamic>?;
      if (results == null) {
        debugPrint('❌ [API] response.body\'de "results" anahtarı bulunamadı!');
        debugPrint('   Mevcut anahtarlar: ${data.keys.toList()}');
        break;
      }

      debugPrint('📦 [API] Sayfa $pageNumber: ${results.length} sonuç geldi.');

      int addedCount = 0;
      int skippedCount = 0;

      for (var i = 0; i < results.length; i++) {
        try {
          final result = results[i];
          final atm = AtmPlace.fromJson({
            ...result,
            'id': result['place_id'] ?? '',
          });

          final distance = atm.calculateDistance(latitude, longitude);
          if (distance <= maxDistanceMeters) {
            atmResults.add(atm);
            addedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          debugPrint('⚠️ [API] Sayfa $pageNumber, sonuç $i parse hatası: $e');
          debugPrint('   Ham veri: ${results[i]}');
        }
      }

      debugPrint('   ✅ $addedCount ATM eklendi, $skippedCount mesafe dışı atlandı.');
      debugPrint('   Toplam şu ana kadar: ${atmResults.length} ATM');

      // ── Sonraki sayfa kontrolü ──
      nextPageToken = data['next_page_token'];
      if (nextPageToken != null && pageNumber < maxPages) {
        debugPrint('⏳ [API] Sonraki sayfa mevcut, 2 sn bekleniyor...');
        await Future.delayed(const Duration(seconds: 2));
      } else {
        nextPageToken = null; // maxPages'e ulaştıysa döngüyü kır
      }
    } while (nextPageToken != null);

    debugPrint('🏁 [API] Toplam $pageNumber sayfa tarandı, ${atmResults.length} ATM bulundu.');
    return atmResults;
  }

  /// Raporlarla zenginleştirir ve mesafeye göre sıralar.
  static Future<List<AtmPlace>> _enrichAndSort(
    List<AtmPlace> atms,
    double latitude,
    double longitude,
  ) async {
    final enriched = await Future.wait(
      atms.map((atm) => FirestoreReportService.enrichWithReports(atm)),
    );

    enriched.sort((a, b) =>
      a.calculateDistance(latitude, longitude).compareTo(
        b.calculateDistance(latitude, longitude),
      ));

    return enriched;
  }

  static String normalizeBankName(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('ziraat')) return 'Ziraat';
    if (lower.contains('vakıf') || lower.contains('vakif')) return 'VakıfBank';
    if (lower.contains('halk')) return 'Halkbank';
    if (lower.contains('iş') || lower.contains('is ') || lower.contains('isbank') || lower.contains('işbank') || lower.contains('bankamatik')) return 'İş Bankası';
    if (lower.contains('garanti')) return 'Garanti BBVA';
    if (lower.contains('qnb') || lower.contains('finansbank')) return 'QNB Finansbank';
    if (lower.contains('yapı') || lower.contains('kredi') || lower.contains('yapi') || lower.contains('yapıkredi')) return 'Yapı Kredi';
    if (lower.contains('akbank')) return 'Akbank';
    if (lower.contains('ing')) return 'ING';
    if (lower.contains('teb') || lower.contains('ekonomi')) return 'TEB';
    if (lower.contains('deniz')) return 'DenizBank';
    if (lower.contains('kuveyt')) return 'Kuveyt Türk';
    if (lower.contains('albaraka')) return 'Albaraka';
    if (lower.contains('şeker') || lower.contains('seker')) return 'Şekerbank';
    if (lower.contains('hsbc')) return 'HSBC';

    return 'Diğer';
  }
}
