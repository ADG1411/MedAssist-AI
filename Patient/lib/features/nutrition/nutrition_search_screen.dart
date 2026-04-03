// Nutrition Search Screen  ported & customized from OpenNutriTracker AddMealScreen
// Adapted for MedAssist: Riverpod, MedAssist theme, cascade search (Indian  OFF  FDC)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medassist_ai/core/theme/app_colors.dart';
import 'package:medassist_ai/features/nutrition/models/intake_entry.dart';
import 'package:medassist_ai/features/nutrition/models/meal_entity.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_providers.dart';

class NutritionSearchScreen extends ConsumerStatefulWidget {
  final MealType? initialMealType;
  const NutritionSearchScreen({super.key, this.initialMealType});

  @override
  ConsumerState<NutritionSearchScreen> createState() => _NutritionSearchScreenState();
}

class _NutritionSearchScreenState extends ConsumerState<NutritionSearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  bool _indianOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(nutritionSearchProvider.notifier).search(query, indianOnly: _indianOnly);
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(nutritionSearchProvider);
    final mealTypeName = widget.initialMealType?.label ?? 'Add Food';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(mealTypeName),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: ' Indian'),
            Tab(text: 'Recent'),
          ],
          onTap: (i) {
            if (i == 1) {
              setState(() => _indianOnly = true);
              _onSearch(_searchController.text);
            } else {
              setState(() => _indianOnly = false);
              if (i == 0 && _searchController.text.isNotEmpty) {
                _onSearch(_searchController.text);
              }
            }
          },
        ),
      ),
      body: Column(
        children: [
          //  Search Bar 
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        if (v.length > 1) _onSearch(v);
                      },
                      onSubmitted: _onSearch,
                      decoration: InputDecoration(
                        hintText: _indianOnly
                            ? 'Search dal, roti, biryani...'
                            : 'Search foods, brands...',
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(nutritionSearchProvider.notifier).clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Image scan button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    tooltip: 'Scan Food Photo',
                    onPressed: () => context.push('/nutrition/image-scan',
                        extra: widget.initialMealType),
                  ),
                ),
                const SizedBox(width: 8),
                // Barcode button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    onPressed: () => context.push('/nutrition/barcode',
                        extra: widget.initialMealType),
                  ),
                ),
              ],
            ),
          ),

          //  Results 
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Tab 0: Search
                _buildFoodList(search),
                // Tab 1: Indian only
                _buildFoodList(search),
                // Tab 2: Recent
                _buildRecentList(search.recentFoods),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(NutritionSearchState search) {
    if (search.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (search.query.isEmpty) {
      return _buildEmptyState();
    }

    if (search.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text('No results for "${search.query}"',
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: search.results.length,
      itemBuilder: (_, i) => _FoodResultCard(
        meal: search.results[i],
        onTap: () => _openFoodDetail(search.results[i]),
      ),
    );
  }

  Widget _buildRecentList(List<IntakeEntry> recents) {
    if (recents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('No recently logged foods',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: recents.length,
      itemBuilder: (_, i) => _FoodResultCard(
        meal: recents[i].meal,
        onTap: () => _openFoodDetail(recents[i].meal),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Icon(Icons.restaurant_menu, size: 72, color: AppColors.softBlue),
        const SizedBox(height: 16),
        const Text('Search for foods', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Indian foods  Global products  Scan barcode',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 32),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Try: dal makhani, paneer, apple, chicken',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
      ],
    );
  }

  void _openFoodDetail(MealEntity meal) {
    context.push('/nutrition/food-detail', extra: {
      'meal': meal,
      'mealType': widget.initialMealType,
    });
  }
}

//  Food Result Card 
class _FoodResultCard extends StatelessWidget {
  final MealEntity meal;
  final VoidCallback onTap;

  const _FoodResultCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final kcal = meal.nutriments.energyKcal100?.toStringAsFixed(0) ?? '--';
    final sourceLabel = _sourceLabel(meal.source);
    final srcColor = _sourceColor(meal.source);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Food image or placeholder
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: meal.thumbnailImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        meal.thumbnailImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.restaurant, color: AppColors.primary),
                      ),
                    )
                  : const Icon(Icons.restaurant, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meal.brands != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      meal.brands!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MacroChip(label: '$kcal kcal/100g', color: AppColors.warning),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: srcColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sourceLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: srcColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _sourceLabel(MealSource s) {
    switch (s) {
      case MealSource.indian: return ' IFCT';
      case MealSource.off: return ' OFF';
      case MealSource.fdc: return ' USDA';
      default: return ' Custom';
    }
  }

  Color _sourceColor(MealSource s) {
    switch (s) {
      case MealSource.indian: return Colors.orange;
      case MealSource.off: return AppColors.success;
      case MealSource.fdc: return AppColors.primary;
      default: return AppColors.textSecondary;
    }
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

