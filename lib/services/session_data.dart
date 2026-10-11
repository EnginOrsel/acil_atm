import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:acil_atm/models/atm_place.dart';
import 'package:acil_atm/services/location_service.dart';
import 'package:acil_atm/services/api/google_places_service.dart';

class SessionData {
  static final SessionData _instance = SessionData._internal();
  factory SessionData() => _instance;
  SessionData._internal();

  late Position userPosition;
  List<AtmPlace> atmList = [];

  static String normalizeBankName(String name) {
    return GooglePlacesService.normalizeBankName(name);
  }

  Future<void> initialize() async {
    if (atmList.isNotEmpty) {
      debugPrint('📌 [SessionData] Zaten başlatılmış, ${atmList.length} ATM mevcut.');
      return;
    }

    // Konum al
    try {
      debugPrint('📌 [SessionData] Konum alınıyor...');
      userPosition = await LocationService.getCurrentLocation();
      debugPrint('✅ [SessionData] Konum alındı: ${userPosition.latitude}, ${userPosition.longitude}');
    } catch (e, stack) {
      debugPrint('❌ [SessionData] KONUM HATASI: $e');
      debugPrint('   Stack: $stack');
      rethrow;
    }

    // ATM verilerini çek
    try {
      debugPrint('📌 [SessionData] ATM verileri çekiliyor...');
      atmList = await GooglePlacesService.fetchNearbyAtms(
        userPosition.latitude,
        userPosition.longitude,
      );
      debugPrint('✅ [SessionData] ${atmList.length} ATM yüklendi.');
    } catch (e, stack) {
      debugPrint('❌ [SessionData] ATM VERİ HATASI: $e');
      debugPrint('   Stack: $stack');
      rethrow;
    }
  }
}