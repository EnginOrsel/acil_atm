import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Banka kurumsal renginde özel harita pin'i oluşturur.
/// Pin: Üstte yuvarlak baş (ATM ikonu + renk), altta sivri uç.
class AtmMarkerPainter {
  AtmMarkerPainter._();

  /// Verilen renkle özel bir pin BitmapDescriptor oluşturur.
  static Future<BitmapDescriptor> createColoredPin(Color bankColor) async {
    const double pinWidth = 80;
    const double pinHeight = 100;
    const double circleRadius = 30;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, pinWidth, pinHeight),
    );

    // Gölge
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(
      const Offset(pinWidth / 2, circleRadius + 3),
      circleRadius + 2,
      shadowPaint,
    );

    // Sivri uç (üçgen)
    final pinTailPaint = Paint()..color = bankColor;
    final tailPath = Path()
      ..moveTo(pinWidth / 2 - 12, circleRadius + 18)
      ..lineTo(pinWidth / 2, pinHeight - 4)
      ..lineTo(pinWidth / 2 + 12, circleRadius + 18)
      ..close();
    canvas.drawPath(tailPath, pinTailPaint);

    // Dış daire (beyaz kenarlık)
    final borderPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      const Offset(pinWidth / 2, circleRadius + 2),
      circleRadius + 3,
      borderPaint,
    );

    // İç daire (banka rengi)
    final circlePaint = Paint()..color = bankColor;
    canvas.drawCircle(
      const Offset(pinWidth / 2, circleRadius + 2),
      circleRadius,
      circlePaint,
    );

    // ATM ikonu (₺ sembolü veya basit çizim)
    final iconColor = ThemeData.estimateBrightnessForColor(bankColor) == Brightness.light
        ? Colors.black87
        : Colors.white;

    // ATM kutusu çizimi
    _drawAtmIcon(canvas, pinWidth / 2, circleRadius + 2, iconColor);

    final picture = recorder.endRecording();
    final image = await picture.toImage(pinWidth.toInt(), pinHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }

    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }

  /// Pin içine basit bir ATM/para simgesi çizer
  static void _drawAtmIcon(Canvas canvas, double cx, double cy, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // ATM kutusu
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 26, height: 20),
      const Radius.circular(3),
    );
    canvas.drawRRect(boxRect, paint);

    // Ekran (üst kısım)
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 3), width: 18, height: 8),
      const Radius.circular(1.5),
    );
    final screenPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(screenRect, screenPaint);

    // Kart yuvası (alt çizgi)
    canvas.drawLine(
      Offset(cx - 6, cy + 6),
      Offset(cx + 6, cy + 6),
      paint,
    );
  }

  /// Renklere göre önbellek ile marker oluşturur (aynı renk tekrar çizilmez)
  static final Map<int, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> getCachedPin(Color bankColor) async {
    final key = bankColor.value;
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    final descriptor = await createColoredPin(bankColor);
    _cache[key] = descriptor;
    return descriptor;
  }
}
