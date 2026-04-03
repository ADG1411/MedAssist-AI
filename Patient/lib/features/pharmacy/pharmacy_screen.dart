import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/app_empty_list.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/app_button.dart';
import 'providers/pharmacy_provider.dart';

class PharmacyScreen extends ConsumerWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pharmacyProvider);
    final notifier = ref.read(pharmacyProvider.notifier);
    final medicines = state.filteredMedicines;

    return BaseScreen(
      appBar: AppBar(
        title: const Text('MedAssist Pharmacy'),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: notifier.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
          ),
          Container(
             color: AppColors.primary.withValues(alpha: 0.1),
             width: double.infinity,
             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
             child: const Text(' Save up to 70% by choosing Generic Alternatives!', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: medicines.isEmpty
                ? const AppEmptyList(
                    title: 'No medicines found',
                    subtitle: 'Check spelling or consult your assigned doctor via Tickets.',
                    icon: Icons.medication_liquid,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _MedicineCard(medicine: medicines[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Map<String, dynamic> medicine;

  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final bool pxReq = medicine['isPrescriptionRequired'] ?? false;
    final double brandPrice = (medicine['brandPrice'] ?? 0).toDouble();
    final double genPrice = (medicine['genericPrice'] ?? 0).toDouble();

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medicine['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(medicine['genericName'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              if (pxReq)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Rx Required', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top Brand Price', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                     Text('$brandPrice', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Row(children: [Icon(Icons.eco, size: 14, color: AppColors.success), SizedBox(width: 4), Text('Generic Price', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold))]),
                       const SizedBox(height: 4),
                       Text('$genPrice', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 18)),
                     ],
                   ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Order Generic',
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart!')));
            },
          ),
        ],
      ),
    );
  }
}

