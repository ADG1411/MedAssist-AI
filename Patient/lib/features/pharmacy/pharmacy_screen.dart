import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/app_empty_list.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/app_button.dart';
import '../records/providers/records_provider.dart';
import 'providers/pharmacy_provider.dart';

class PharmacyScreen extends ConsumerWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pharmacyProvider);
    final notifier = ref.read(pharmacyProvider.notifier);
    final medicines = state.filteredMedicines;
    
    // Check if user has uploaded health records to provide smart recommendations
    final recordsState = ref.watch(recordsProvider);
    final hasRecords = recordsState.value?.allRecords.isNotEmpty ?? false;

    return BaseScreen(
      appBar: AppBar(
        title: const Text('MedAssist Pharmacy'),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  onChanged: notifier.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16).copyWith(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Smart Recommendations Section
                  if (hasRecords && state.searchQuery.isEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        const Text('Based on your Medical Records', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _MedicineCard(
                      medicine: medicines.firstWhere((m) => m['name'] == 'Augmentin 625 Duo', orElse: () => medicines.first),
                      isRecommendation: true,
                    ),
                    const SizedBox(height: 24),
                    const Text('Available Generic Alternatives', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                  ],

                  if (medicines.isEmpty)
                    const AppEmptyList(
                      title: 'No medicines found',
                      subtitle: 'Check spelling or consult your assigned doctor via Tickets.',
                      icon: Icons.medication_liquid,
                    )
                  else
                    ...medicines.map((medicine) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _MedicineCard(medicine: medicine, isRecommendation: false),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Map<String, dynamic> medicine;
  final bool isRecommendation;

  const _MedicineCard({required this.medicine, this.isRecommendation = false});

  @override
  Widget build(BuildContext context) {
    final bool pxReq = medicine['isPrescriptionRequired'] ?? false;
    final double brandPrice = (medicine['brandPrice'] ?? 0).toDouble();
    final double genPrice = (medicine['genericPrice'] ?? 0).toDouble();
    final double savings = brandPrice - genPrice;
    final double savingsPct = (savings / brandPrice) * 100;

    return AppSectionCard(
      child: Container(
        decoration: isRecommendation 
          ? BoxDecoration(
              border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 2),
              borderRadius: BorderRadius.circular(16)
            ) 
          : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommendation)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                ),
                child: const Text('★ Recommended for your recent illness', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            Padding(
              padding: EdgeInsets.all(isRecommendation ? 16.0 : 0),
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
                            Text(medicine['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text(medicine['genericName'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (pxReq)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Text('Rx Required', style: TextStyle(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Price Comparison Block
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        // Brand Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Top Brand', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                               Text('₹${brandPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough, color: AppColors.textSecondary, fontSize: 16)),
                            ],
                          ),
                        ),
                        
                        Container(width: 1, height: 30, color: AppColors.border.withOpacity(0.5)),
                        
                        // Generic Price
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(Icons.eco, size: 14, color: AppColors.success), 
                                  const SizedBox(width: 4), 
                                  const Text('MedAssist Generic', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w800))
                                ]),
                                const SizedBox(height: 4),
                                Text('₹${genPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontSize: 22)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Savings banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('Save ${savingsPct.toStringAsFixed(0)}% (₹${savings.toStringAsFixed(0)})', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                      
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${medicine['name']} added to cart!', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.primary));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Add Generic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

