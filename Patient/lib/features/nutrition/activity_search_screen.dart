import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medassist_ai/core/theme/app_colors.dart';
import 'package:medassist_ai/features/auth/providers/auth_provider.dart';
import 'package:medassist_ai/features/nutrition/models/activity_entry.dart';
import 'package:medassist_ai/features/nutrition/models/physical_activity_catalog.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_providers.dart';
import 'package:uuid/uuid.dart';

class ActivitySearchScreen extends ConsumerStatefulWidget {
  const ActivitySearchScreen({super.key});

  @override
  ConsumerState<ActivitySearchScreen> createState() => _ActivitySearchScreenState();
}

class _ActivitySearchScreenState extends ConsumerState<ActivitySearchScreen> {
  final _searchController = TextEditingController();
  List<PhysicalActivityCatalogEntry> _results = ActivityCatalog.activities;

  void _onSearch(String query) {
    setState(() {
      _results = ActivityCatalog.search(query);
    });
  }

  void _showAddDialog(PhysicalActivityCatalogEntry activity) {
    double durationMin = 30;
    
    // Fallback to 70kg if user weight is missing or unparseable
    final profile = ref.read(authProvider);
    double weightKg = 70.0;
    if (profile != null && profile['weight_kg'] != null) {
      if (profile['weight_kg'] is num) {
        weightKg = (profile['weight_kg'] as num).toDouble();
      } else if (profile['weight_kg'] is String) {
        weightKg = double.tryParse(profile['weight_kg']) ?? 70.0;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final burn = activity.mets * weightKg * (durationMin / 60.0);
          
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(activity.icon, size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(activity.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Text('${burn.toInt()} kcal', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.success)),
                const Text('Estimated Calories Burned', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Duration (min)', style: TextStyle(fontSize: 16)),
                    Text('${durationMin.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: durationMin,
                  min: 5,
                  max: 180,
                  divisions: 35,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setModalState(() => durationMin = val);
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      final log = ActivityEntry(
                        id: const Uuid().v4(),
                        date: DateTime.now(),
                        code: activity.code,
                        name: activity.name,
                        durationMin: durationMin,
                        caloriesBurned: burn,
                      );
                      ref.read(nutritionDiaryProvider.notifier).logActivity(log);
                      context.pop(); // close modal
                      context.pop(); // close search screen
                    },
                    child: const Text('Log Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Activity'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for an exercise...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final a = _results[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.softBlue,
                    foregroundColor: AppColors.primary,
                    child: Icon(a.icon),
                  ),
                  title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(a.description),
                  trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  onTap: () => _showAddDialog(a),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

