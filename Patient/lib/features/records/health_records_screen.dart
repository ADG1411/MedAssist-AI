import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/app_empty_list.dart';
import '../../shared/widgets/shimmer_box.dart';
import 'widgets/record_ai_card.dart';
import 'providers/records_provider.dart';

class HealthRecordsScreen extends ConsumerWidget {
  const HealthRecordsScreen({super.key});

  final List<String> _filters = const ['All', 'Prescription', 'AI Result', 'Lab Report', 'Imaging'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(recordsProvider);

    return BaseScreen(
      appBar: AppBar(
        title: const Text('Medical Records AI Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => context.push('/medassist-card'),
            tooltip: 'Health QR',
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => _buildLoading(),
        error: (e, _) => _buildError(ref),
        data: (state) => _buildData(context, ref, state),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleUpload(context, ref),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload to Vault'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _handleUpload(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulating file pick & AI OCR parsing...'), duration: Duration(seconds: 1)),
    );
    
    final success = await ref.read(recordsProvider.notifier).uploadAndProcessRecord();
    
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record successfully added to vault and summarized.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed.')));
      }
    }
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(4, (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ShimmerBox(height: 80, borderRadius: 16),
        )),
      ),
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('Failed to load records'),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => ref.read(recordsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildData(BuildContext context, WidgetRef ref, RecordsState state) {
    final records = state.filteredRecords;
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = state.activeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(filter, style: const TextStyle(fontSize: 13)),
                  selected: isSelected,
                  onSelected: (_) => ref.read(recordsProvider.notifier).setFilter(filter),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? const AppEmptyList(
                  title: 'No records found',
                  subtitle: 'No documents match this category yet.',
                  icon: Icons.folder_open,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: RecordAiCard(record: records[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

