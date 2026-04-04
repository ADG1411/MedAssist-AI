import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/hospital_card.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  List<Map<String, dynamic>> _hospitals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      final data = await Supabase.instance.client.from('hospitals').select();
      if (mounted) {
        setState(() {
          _hospitals = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (e) {
      // Return empty if table doesn't exist or fails
      if (mounted) {
        setState(() {
          _hospitals = [];
          _loading = false;
        });
      }
    }
  }

  static const List<Map<String, dynamic>> _fallbackHospitals = [
    {
      'id': 'h1',
      'name': 'City Central General Hospital',
      'address': '124 Medical Way, Downtown Block',
      'distance': '1.2',
      'has_emergency': true,
    },
    {
      'id': 'h2',
      'name': 'Sunrise Care Clinic',
      'address': 'Sunset Blvd, East Sector',
      'distance': '3.4',
      'has_emergency': false,
    },
    {
      'id': 'h3',
      'name': 'Apollo Multi-Specialty',
      'address': 'Ring Road Extension',
      'distance': '5.0',
      'has_emergency': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: AppBar(
        title: const Text('Find Hospitals'),
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/sos'),
        backgroundColor: AppColors.danger,
        child: const Icon(Icons.sos, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // Map Placeholder
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Container(color: Colors.grey[300]!.withValues(alpha: 0.8)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 48, color: AppColors.danger),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: const Text('Live Map View Active', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nearby Hospitals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('${_hospitals.length} found', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                    itemCount: _hospitals.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: HospitalCard(
                          hospital: _hospitals[index],
                          onDirectionsTap: () {},
                          onCallTap: () {},
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
