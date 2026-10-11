import 'dart:math';
import 'package:flutter/material.dart';
import 'package:acil_atm/utils/bank_theme_helper.dart';

class AtmPlace {
  final String id;
  final String name;
  final String bankId;
  final double lat;
  final double lng;
  final String? address;

  final String? lastReportedProblem;
  final int directedUserCount;

  final int reportCount;
  final List<String>? reportDetails;

  AtmPlace({
    required this.id,
    required this.name,
    this.bankId = '',
    required this.lat,
    required this.lng,
    this.address,
    this.lastReportedProblem,
    this.directedUserCount = 0,
    this.reportCount = 0,
    this.reportDetails,
  });

  /// Bu ATM'nin ait olduğu bankanın kurumsal rengi
  Color get bankColor => BankThemeHelper.getBankColor(name);

  /// Bu ATM'nin ait olduğu bankanın kısa adı (avatar için)
  String get bankInitials => BankThemeHelper.getBankInitials(name);

  factory AtmPlace.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? 'Bilinmeyen ATM';
    return AtmPlace(
      id: json['id'] ?? '',
      bankId: json['bankId'] ?? BankThemeHelper.resolveBankKey(name) ?? '',
      name: name,
      lat: (json['lat'] ?? json['geometry']?['location']?['lat'])?.toDouble() ?? 0.0,
      lng: (json['lng'] ?? json['geometry']?['location']?['lng'])?.toDouble() ?? 0.0,
      address: json['address'] ?? json['vicinity'] ?? '',
      lastReportedProblem: json['lastReportedProblem'],
      directedUserCount: json['directedUserCount'] ?? 0,
      reportCount: json['reportCount'] ?? 0,
      reportDetails: (json['reportDetails'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankId': bankId,
      'name': name,
      'lat': lat,
      'lng': lng,
      'address': address,
      'lastReportedProblem': lastReportedProblem,
      'directedUserCount': directedUserCount,
      'reportCount': reportCount,
      'reportDetails': reportDetails,
    };
  }

  double calculateDistance(double userLat, double userLng) {
    const earthRadius = 6371000;

    final dLat = _degreesToRadians(lat - userLat);
    final dLng = _degreesToRadians(lng - userLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(userLat)) *
            cos(_degreesToRadians(lat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
