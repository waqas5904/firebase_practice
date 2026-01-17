import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapProvider extends ChangeNotifier {
  LatLng? _currentPosition;
  LatLng? _destinationPosition;

  String _address = "Fetching location...";
  String _distance = "0 km";
  String _instruction = "Select a destination";
  String _placeImage =
      "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=2047";

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;

  LatLng? get currentPosition => _currentPosition;
  LatLng? get destinationPosition => _destinationPosition;
  String get address => _address;
  String get distance => _distance;
  String get instruction => _instruction;
  String get placeImage => _placeImage;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;

  MapProvider() {
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);

    _addMarker(
      _currentPosition!,
      "My Location",
      iconHue: BitmapDescriptor.hueBlue,
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 15),
    );
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    }
  }

  void _addMarker(
    LatLng position,
    String title, {
    double iconHue = BitmapDescriptor.hueRed,
  }) {
    _markers.add(
      Marker(
        markerId: MarkerId(title),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarkerWithHue(iconHue),
      ),
    );
  }

  Future<void> handleTap(LatLng tappedPoint) async {
    if (_currentPosition == null) return;

    _destinationPosition = tappedPoint;
    _instruction = "Navigating to destination";

    // 1. Update Markers
    _markers.clear();
    _addMarker(_currentPosition!, "Start", iconHue: BitmapDescriptor.hueBlue);
    _addMarker(
      _destinationPosition!,
      "Destination",
      iconHue: BitmapDescriptor.hueViolet,
    );

    // 2. Draw Polyline (Line from A to B)
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: [_currentPosition!, _destinationPosition!],
        color: const Color(0xFF7B61FF),
        width: 6,
        jointType: JointType.round,
      ),
    );

    // 3. Get Real Address
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        tappedPoint.latitude,
        tappedPoint.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _address = "${place.street}, ${place.subLocality}";
      }
    } catch (e) {
      _address = "Unnamed Road";
    }

    // 4. Calculate Real Distance
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      tappedPoint.latitude,
      tappedPoint.longitude,
    );

    if (distanceInMeters < 1000) {
      _distance = "${distanceInMeters.toStringAsFixed(0)} meters";
    } else {
      _distance = "${(distanceInMeters / 1000).toStringAsFixed(2)} km";
    }

    // 5. Change Image based on location (Dynamic feel)
    _placeImage =
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073&auto=format&fit=crop"; // Beach image as example

    notifyListeners();
  }
}
