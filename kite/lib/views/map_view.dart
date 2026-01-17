import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kite/providers/map_provider.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  static const String _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#c9c9c9"}]
  }
]
''';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapProvider(),
      child: Scaffold(
        body: Consumer<MapProvider>(
          builder: (context, provider, child) {
            if (provider.currentPosition == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Getting your location..."),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                // 1. Google Map Base
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: provider.currentPosition!,
                    zoom: 15.0,
                  ),
                  onMapCreated: (controller) {
                    provider.onMapCreated(controller);
                    controller.setMapStyle(_mapStyle);
                  },
                  markers: provider.markers,
                  polylines: provider.polylines,
                  onTap: (LatLng position) {
                    provider.handleTap(position);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                ),

                // 2. Custom Floating Marker Label
                if (provider.destinationPosition != null)
                  Positioned(
                    top: 100,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                        child: const Text(
                          "Destination Selected",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B61FF),
                          ),
                        ),
                      ),
                    ),
                  ),

                // 3. Navigation Card (Purple)
                Positioned(
                  bottom: 110,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B61FF),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B61FF).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Left Image (Dynamic)
                        Hero(
                          tag: 'location_img',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              provider.placeImage,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                provider.instruction.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.address,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      provider.distance,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.directions_car,
                          color: Colors.white.withOpacity(0.5),
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Footer Controls
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F2FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Color(0xFF7B61FF),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.layers, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 64,
                          width: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
