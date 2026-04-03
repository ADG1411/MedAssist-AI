import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Sort/filter enum for the doctor discovery screen.
enum DoctorSort { aiMatch, earliestSlot, topRated, mostExperienced, lowestFee, nearby }

extension DoctorSortLabel on DoctorSort {
  String get label {
    switch (this) {
      case DoctorSort.aiMatch:         return 'AI Match';
      case DoctorSort.earliestSlot:    return 'Earliest Slot';
      case DoctorSort.topRated:        return 'Top Rated';
      case DoctorSort.mostExperienced: return 'Most Experienced';
      case DoctorSort.lowestFee:       return 'Lowest Fee';
      case DoctorSort.nearby:          return 'Nearby';
    }
  }

  IconData get icon {
    switch (this) {
      case DoctorSort.aiMatch:         return Icons.auto_awesome;
      case DoctorSort.earliestSlot:    return Icons.flash_on_rounded;
      case DoctorSort.topRated:        return Icons.star_rounded;
      case DoctorSort.mostExperienced: return Icons.workspace_premium_rounded;
      case DoctorSort.lowestFee:       return Icons.savings_rounded;
      case DoctorSort.nearby:          return Icons.location_on_rounded;
    }
  }
}

class DoctorFilterCommandBar extends StatelessWidget {
  final TextEditingController searchController;
  final String activeSpecialty;
  final DoctorSort activeSort;
  final List<String> specialties;
  final ValueChanged<String> onSpecialtyChanged;
  final ValueChanged<DoctorSort> onSortChanged;
  final ValueChanged<String> onSearchChanged;

  const DoctorFilterCommandBar({
    super.key,
    required this.searchController,
    required this.activeSpecialty,
    required this.activeSort,
    required this.specialties,
    required this.onSpecialtyChanged,
    required this.onSortChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          color: isDark
              ? Colors.black.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.72),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : AppColors.border.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search_rounded,
                          size: 18,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search doctors, hospitals, symptoms...',
                            hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.38)
                                    : AppColors.textSecondary),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.close_rounded,
                                size: 16,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.45)
                                    : AppColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Sort chips
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: DoctorSort.values.map((sort) {
                    final isActive = activeSort == sort;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => onSortChanged(sort),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withValues(alpha: 0.14)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : Colors.white.withValues(alpha: 0.80)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary.withValues(alpha: 0.35)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : AppColors.border
                                          .withValues(alpha: 0.30)),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(sort.icon,
                                  size: 12,
                                  color: isActive
                                      ? AppColors.primary
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.55)
                                          : AppColors.textSecondary)),
                              const SizedBox(width: 5),
                              Text(sort.label,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isActive
                                          ? AppColors.primary
                                          : (isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.65)
                                              : AppColors.textSecondary))),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Specialty chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                  itemCount: specialties.length,
                  itemBuilder: (context, index) {
                    final spec = specialties[index];
                    final isSelected = activeSpecialty == spec;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => onSpecialtyChanged(spec),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.white.withValues(alpha: 0.85)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : AppColors.border
                                          .withValues(alpha: 0.30)),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            spec,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.75)
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
