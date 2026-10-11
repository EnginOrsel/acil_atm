import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:acil_atm/services/session_data.dart';
import 'package:acil_atm/utils/atm_marker_painter.dart';
import 'package:acil_atm/widgets/atm_card/atm_detail_bottom_sheet.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Map<MarkerId, Marker> _markers = {};
  late LatLng _initialPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      await SessionData().initialize();

      final atmList = SessionData().atmList;
      final userPosition = SessionData().userPosition;

      _initialPosition = LatLng(userPosition.latitude, userPosition.longitude);

      for (var i = 0; i < atmList.length; i++) {
        final atm = atmList[i];
        final markerId = MarkerId('atm_$i');
        final icon = await AtmMarkerPainter.getCachedPin(atm.bankColor);
        final distance = atm.calculateDistance(userPosition.latitude, userPosition.longitude).round();

        final marker = Marker(
          markerId: markerId,
          position: LatLng(atm.lat, atm.lng),
          icon: icon,
          onTap: () {
            _moveCameraTo(atm.lat, atm.lng); // Zoom animasyonu burada
            showAtmDetailsBottomSheet(context, atm, distance);
          },
        );

        _markers[markerId] = marker;
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Harita verileri yüklenemedi: $e");
    }
  }

  void _moveCameraTo(double lat, double lng) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_markers.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ATM Haritası"),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 15),
        markers: Set<Marker>.of(_markers.values),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          _controller.complete(controller);
          _mapController = controller;
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
