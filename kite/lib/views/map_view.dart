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
    final searchController = TextEditingController();

    return ChangeNotifierProvider(
      create: (_) => MapProvider(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Consumer<MapProvider>(
          builder: (context, provider, child) {
            if (provider.currentPosition == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF7B61FF)),
                    SizedBox(height: 16),
                    Text("Initializing Professional Map..."),
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

                // 2. SEARCH BAR (Professional)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search location (e.g. Gurumandir)",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF7B61FF),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            provider.searchLocation(searchController.text);
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFF7B61FF),
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      onSubmitted: (value) {
                        provider.searchLocation(value);
                      },
                    ),
                  ),
                ),

                // 3. Navigation Card (Purple) - Integrated with Dynamic Data
                Positioned(
                  bottom: 110,
                  left: 20,
                  right: 20,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
                        // Dynamic Image of the Place
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImageSim(
                            imageUrl: provider.placeImage,
                            width: 120,
                            height: 120,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                provider.instruction.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.address,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      provider.distance,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                      _buildPillButton(
                        icon: Icons.my_location,
                        onTap: () {
                          // Already handled by GoogleMap myLocationEnabled, but can zoom
                        },
                      ),
                      const Spacer(),
                      _buildCloseButton(context),
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

  Widget _buildPillButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 64,
      width: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF7B61FF)),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 64,
        width: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 32),
      ),
    );
  }
}

// Simulated Cached Image for performance and dynamic look
class CachedNetworkImageSim extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const CachedNetworkImageSim({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.white),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}
