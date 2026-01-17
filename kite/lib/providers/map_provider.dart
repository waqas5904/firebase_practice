import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapProvider extends ChangeNotifier {
  // IMPORTANT: Use your Google Cloud Console API Key here
  static const String _googleApiKey = "AIzaSyBckYwsqQyol7JjOlQNTkD7HgVjjqr5cBk";

  LatLng? _currentPosition;
  LatLng? _destinationPosition;

  String _address = "Search for a place...";
  String _distance = "0 km";
  String _instruction = "Pick a destination";
  String _placeImage =
      "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=2047";

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  List<dynamic> _suggestions = [];
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;
  Timer? _debounce;

  LatLng? get currentPosition => _currentPosition;
  LatLng? get destinationPosition => _destinationPosition;
  String get address => _address;
  String get distance => _distance;
  String get instruction => _instruction;
  String get placeImage => _placeImage;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  List<dynamic> get suggestions => _suggestions;
  GoogleMapController? get mapController => _mapController;

  MapProvider() {
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Get Initial Position
    Position position = await Geolocator.getCurrentPosition();
    _updateMyPosition(position);

    // Start Live Tracking
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          _updateMyPosition(position);
        });
  }

  void _updateMyPosition(Position position) {
    _currentPosition = LatLng(position.latitude, position.longitude);
    if (_destinationPosition != null) {
      _getRoadRoute();
      _calculateStats();
    } else {
      _updateMarkersAndPolylines();
    }
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

  Future<void> getPlaceSuggestions(String query) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (query.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final String url =
            "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey";
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            _suggestions = data['predictions'];
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint("Suggestions error: $e");
      }
    });
  }

  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        LatLng target = LatLng(locations[0].latitude, locations[0].longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 15));
        handleTap(target);
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  Future<void> handleTap(LatLng tappedPoint) async {
    _destinationPosition = tappedPoint;
    _instruction = "Follow the road route";

    // Get Address
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        tappedPoint.latitude,
        tappedPoint.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _address =
            "${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}";
      }
    } catch (e) {
      _address = "Custom Location";
    }

    // Fetch Real Place Photo from Google Places API
    try {
      final String nearbyUrl =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${tappedPoint.latitude},${tappedPoint.longitude}&radius=50&key=$_googleApiKey";
      final response = await http.get(Uri.parse(nearbyUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final firstPlace = data['results'][0];
          if (firstPlace['photos'] != null && firstPlace['photos'].isNotEmpty) {
            final photoRef = firstPlace['photos'][0]['photo_reference'];
            _placeImage =
                "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoRef&key=$_googleApiKey";

            // Optionally update address to the specific place name found
            if (firstPlace['name'] != null) {
              _address = firstPlace['name'];
            }
          } else {
            // Fallback if no photo
            _placeImage =
                "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=2047";
          }
        }
      }
    } catch (e) {
      debugPrint("Photo fetch error: $e");
      _placeImage =
          "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=2047";
    }

    await _getRoadRoute();
    _calculateStats();
    notifyListeners();
  }

  Future<void> _getRoadRoute() async {
    if (_currentPosition == null || _destinationPosition == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: _googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        destination: PointLatLng(
          _destinationPosition!.latitude,
          _destinationPosition!.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      _polylineCoordinates.clear();
      for (var point in result.points) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      // Fallback to straight line if API fails
      _polylineCoordinates = [_currentPosition!, _destinationPosition!];
      debugPrint("Polyline error: ${result.errorMessage}");
    }
    _updateMarkersAndPolylines();
  }

  void _calculateStats() {
    if (_currentPosition == null || _destinationPosition == null) return;

    double meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _destinationPosition!.latitude,
      _destinationPosition!.longitude,
    );

    _distance = meters < 1000
        ? "${meters.toStringAsFixed(0)} m"
        : "${(meters / 1000).toStringAsFixed(2)} km";
  }

  void _updateMarkersAndPolylines() {
    _markers.clear();
    _polylines.clear();

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("my_pos"),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (_destinationPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("dest_pos"),
          position: _destinationPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );

      if (_polylineCoordinates.isNotEmpty) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("road_route"),
            points: _polylineCoordinates,
            color: const Color(0xFF7B61FF),
            width: 6,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
