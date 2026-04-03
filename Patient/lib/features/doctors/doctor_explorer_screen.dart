import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/app_empty_list.dart';
import '../../shared/widgets/shimmer_box.dart';
import 'providers/doctor_provider.dart';
import 'widgets/doctor_card.dart';
import 'widgets/ai_match_banner.dart';

class DoctorExplorerScreen extends ConsumerWidget {
  const DoctorExplorerScreen({super.key});

  final List<String> _specialties = const [
    'All', 'Cardiology', 'General Practice', 'Gastroenterology', 'Dermatology', 'Neurology', 'Orthopedic'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(doctorFilterProvider);
    final asyncDoctors = ref.watch(doctorsListProvider);
    final asyncAiSpecialty = ref.watch(aiMatchProvider);

    return BaseScreen(
      appBar: AppBar(
        title: const Text('Find a Doctor'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search doctors, hospitals, specialties...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          
          // Specialty Filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _specialties.length,
                itemBuilder: (context, index) {
                  final spec = _specialties[index];
                  final isSelected = activeFilter == spec;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(spec),
                      selected: isSelected,
                      onSelected: (_) => ref.read(doctorFilterProvider.notifier).setFilter(spec),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ),

          // AI Match Banner
          asyncAiSpecialty.when(
            data: (specialty) => specialty != null
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () => ref.read(doctorFilterProvider.notifier).setFilter(specialty),
                        child: AiMatchBanner(specialty: specialty),
                      ),
                    ),
                  )
                : const SliverToBoxAdapter(child: SizedBox.shrink()),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (e, trace) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Doctor List
          asyncDoctors.when(
            data: (doctors) => doctors.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: AppEmptyList(
                        title: 'No doctors found',
                        subtitle: 'Try adjusting your search criteria.',
                        icon: Icons.person_search,
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: DoctorCard(
                          doctor: doctors[index],
                          onTap: () => context.push('/doctor-detail', extra: doctors[index]),
                        ),
                      ),
                      childCount: doctors.length,
                    ),
                  ),
            loading: () => SliverToBoxAdapter(child: _buildLoading()),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error loading doctors: $e')),
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(4, (_) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ShimmerBox(height: 120, borderRadius: 16),
        )),
      ),
    );
  }
}
