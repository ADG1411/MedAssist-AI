import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/hospital_card.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _hospitals = [];
  bool _loading = true;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    try {
      // 1. Get Location Permission and Coordinates
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied forever.');
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(pos.latitude, pos.longitude);
      
      if (mounted) {
        setState(() => _userLocation = latLng);
        // Ensure map exists before animating
        Future.delayed(const Duration(milliseconds: 300), () {
          _mapController.move(latLng, 13.0);
        });
      }

      // 2. Fetch Hospitals from Overpass API (OSM)
      await _fetchOSMHospitals(latLng);

    } catch (e) {
<<<<<<< HEAD
      // Return empty if table doesn't exist or fails
      if (mounted) {
        setState(() {
          _hospitals = [];
          _loading = false;
        });
=======
      debugPrint('Error loading map data: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load location: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.danger),
        );
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
      }
    }
  }

  Future<void> _fetchOSMHospitals(LatLng location) async {
    setState(() => _loading = true);
    final radius = 5000; // 5km
    final query = '''
      [out:json];
      nwr(around:$radius,${location.latitude},${location.longitude})["amenity"="hospital"];
      out center;
    ''';
    
    try {
      final response = await http.get(Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List;
        
        final List<Map<String, dynamic>> parsedHospitals = [];
        for (var el in elements) {
          final tags = el['tags'] ?? {};
          final name = tags['name'] ?? 'Medical Center';
          final lat = el['lat'] ?? el['center']['lat'];
          final lon = el['lon'] ?? el['center']['lon'];
          
          if (lat != null && lon != null) {
            // Calculate distance
            final distInMeters = Geolocator.distanceBetween(location.latitude, location.longitude, lat, lon);
            final distInKm = (distInMeters / 1000).toStringAsFixed(1);
            final phone = tags['phone'] ?? tags['contact:phone'] ?? '';
            
            parsedHospitals.add({
              'id': el['id'].toString(),
              'name': name,
              'address': tags['addr:street'] ?? 'Unknown Address',
              'distance': distInKm,
              'has_emergency': tags['emergency'] == 'yes',
              'phone': phone,
              'lat': lat,
              'lon': lon,
            });
          }
        }
        
        // Sort by distance
        parsedHospitals.sort((a, b) => double.parse(a['distance']).compareTo(double.parse(b['distance'])));

        if (mounted) {
          setState(() {
            _hospitals = parsedHospitals;
            _loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching OSM data: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: AppBar(
        title: const Text('Find Hospitals'),
        leading: BackButton(onPressed: () => context.go('/home')),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/sos'),
        backgroundColor: AppColors.danger,
        child: const Icon(Icons.sos, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // Functional OSM Map
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: _userLocation == null && _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation ?? const LatLng(0, 0),
                    initialZoom: 13.0,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.medassist.app',
                    ),
                    MarkerLayer(
                      markers: [
                        // User location marker
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 24, height: 24,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 8)],
                              ),
                            ),
                          ),
                        // Hospital markers
                        for (var h in _hospitals)
                          if (h['lat'] != null && h['lon'] != null)
                            Marker(
                              point: LatLng(h['lat'] as double, h['lon'] as double),
                              width: 32, height: 32,
                              child: const Icon(Icons.location_on_rounded, color: AppColors.danger, size: 32),
                            ),
                      ],
                    ),
                  ],
                ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nearby Hospitals', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text('${_hospitals.length} found', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: AppColors.background,
              child: _loading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _hospitals.isEmpty 
                      ? const Center(child: Text('No hospitals found in this area.', style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                          itemCount: _hospitals.length,
                          itemBuilder: (context, index) {
                            final h = _hospitals[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: HospitalCard(
                                hospital: h,
                                onDirectionsTap: () async {
                                  if (h['lat'] != null && h['lon'] != null) {
                                    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${h['lat']},${h['lon']}');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Could not open map application')),
                                      );
                                    }
                                  }
                                },
                                onCallTap: () async {
                                  if (h['phone'] != null && h['phone'].toString().isNotEmpty) {
                                    final url = Uri.parse('tel:${h['phone']}');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Could not launch phone dialer')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No phone number listed for this location')),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

