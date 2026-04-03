import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';
import '../../shared/widgets/health_score_ring.dart';
import '../../shared/widgets/quick_action_card.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDashboard = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider) ?? {};
    final userName = user['name']?.toString().split(' ').first ?? 'Guest';

    return BaseScreen(
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_getGreeting()}, $userName!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(),
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: AppColors.softBlue,
                      child: Text(
                        userName.isNotEmpty ? userName[0] : 'G',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            asyncDashboard.when(
              loading: () => SliverToBoxAdapter(child: _buildLoading()),
              error: (e, _) => SliverToBoxAdapter(child: _buildError(ref)),
              data: (data) => SliverToBoxAdapter(child: _buildDashboard(context, data)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        const ShimmerBox(height: 200, borderRadius: 24),
        const SizedBox(height: 24),
        Row(children: const [
          Expanded(child: ShimmerBox(height: 120, borderRadius: 24)),
          SizedBox(width: 16),
          Expanded(child: ShimmerBox(height: 120, borderRadius: 24)),
        ]),
        const SizedBox(height: 16),
        Row(children: const [
          Expanded(child: ShimmerBox(height: 120, borderRadius: 24)),
          SizedBox(width: 16),
          Expanded(child: ShimmerBox(height: 120, borderRadius: 24)),
        ]),
        const SizedBox(height: 32),
        const ShimmerBox(height: 100, borderRadius: 24),
      ],
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('Could not load dashboard'),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, dynamic> data) {
    final healthScore = data['health_score'] as int? ?? 78;
    final latestAi = data['latest_ai_result'] as Map<String, dynamic>?;
    final latestMonitoring = data['latest_monitoring'] as Map<String, dynamic>?;

    final unsafeMeal = data['unsafe_meal'] as Map<String, dynamic>?;
    final recoveryScore = data['recovery_score'] as int?;
    
    // New data points
    final upcomingAppointments = data['upcoming_appointments'] as List<dynamic>? ?? [];
    final medicationReminders = data['medication_reminders'] as List<dynamic>? ?? [];
    final wearableSync = data['wearable_sync'] as Map<String, dynamic>?;
    final profileNudge = data['profile_nudge'] == true;
    final recentLab = data['recent_lab'] as String?;
    final emergencyActive = data['emergency_preparedness'] == true;
    final recoveryVelocity = data['recovery_velocity'] as List<dynamic>? ?? [];

    return Column(
      children: [
        if (profileNudge) ...[
          _buildAlertAlert('Complete Profile', 'Missing core medical data affects AI accuracy.', Icons.person_add_alt_1, AppColors.warning, () => context.push('/onboarding-wizard')),
          const SizedBox(height: 16),
        ],
        if (!emergencyActive) ...[
          _buildAlertAlert('SOS Incomplete', 'No emergency contact configured.', Icons.warning_amber, AppColors.danger, () => context.push('/onboarding-wizard')),
          const SizedBox(height: 16),
        ],

        // 1. Health Score
        AppSectionCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Health Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      healthScore >= 70
                          ? 'You are doing great today! Keep it up.'
                          : 'Your health needs attention today.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              HealthScoreRing(score: healthScore, size: 100, strokeWidth: 10),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Actions
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            QuickActionCard(icon: Icons.personal_injury, label: 'Symptom Check', color: AppColors.primary, onTap: () => context.push('/symptom-check')),
            QuickActionCard(icon: Icons.restaurant_menu, label: 'Nutrition', color: AppColors.success, onTap: () => context.push('/nutrition')),
            QuickActionCard(icon: Icons.medical_services, label: 'Doctors', color: AppColors.warning, onTap: () => context.push('/doctors')),
            QuickActionCard(icon: Icons.emergency, label: 'Emergency SOS', color: AppColors.danger, onTap: () => context.push('/sos')),
          ],
        ),

        const SizedBox(height: 32),

        // Active Monitoring
        if (latestMonitoring != null) ...[
          const SectionHeader(title: 'Today\'s Vitals'),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _vitalTile('Pain', '${latestMonitoring['symptom_severity'] ?? '-'}', Icons.monitor_heart, AppColors.danger),
                _vitalTile('Water', '${latestMonitoring['hydration_cups'] ?? '-'}/8', Icons.water_drop, AppColors.softBlue),
                _vitalTile('Sleep', '${latestMonitoring['sleep_hours'] ?? '-'}h', Icons.bedtime, AppColors.primary),
                _vitalTile('Mood', latestMonitoring['mood'] ?? '-', Icons.mood, AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Latest AI Result
        if (latestAi != null) ...[
          const SectionHeader(title: 'Recent AI Result'),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(latestAi['condition']?.toString() ?? 'Analysis', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    StatusChip(
                      label: '${latestAi['risk'] ?? 'Low'} Risk',
                      variant: (latestAi['risk'] == 'High' || latestAi['risk'] == 'Critical')
                          ? StatusVariant.danger
                          : StatusVariant.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Confidence: ${latestAi['confidence'] ?? 0}%', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => context.push('/ai-result'), child: const Text('View Details')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        const SizedBox(height: 32),

        // 5. Unsafe Meal Alert
        if (unsafeMeal != null) ...[
          _buildAlertAlert('Nutrition Alert', '${unsafeMeal['food_name']} flagged: ${unsafeMeal['conflict']}', Icons.restaurant, AppColors.danger, () {}),
          const SizedBox(height: 32),
        ],

        // 6. Medication Reminders
        if (medicationReminders.isNotEmpty) ...[
          const SectionHeader(title: 'Medications'),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Column(
              children: medicationReminders.map((med) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.medication, color: med['taken'] ? AppColors.success : AppColors.primary),
                title: Text(med['name'], style: TextStyle(decoration: med['taken'] ? TextDecoration.lineThrough : null)),
                subtitle: Text(med['time']),
                trailing: Switch.adaptive(value: med['taken'], onChanged: (v) {}, activeTrackColor: AppColors.success),
              )).toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // 7. Upcoming Appointments
        if (upcomingAppointments.isNotEmpty) ...[
          const SectionHeader(title: 'Upcoming Appointment'),
          const SizedBox(height: 16),
          AppSectionCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: AppColors.softBlue, child: Icon(Icons.person, color: AppColors.primary)),
              title: Text(upcomingAppointments.first['doctor']),
              subtitle: Text('${upcomingAppointments.first['type']} • ${upcomingAppointments.first['time']}'),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // 8. Wearable Sync
        if (wearableSync != null && wearableSync['status'] == true) ...[
          const SectionHeader(title: 'Device Sync'),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.watch, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Health Connect', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Last sync: ${wearableSync['last_sync']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Text('${wearableSync['steps']} steps', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
        
        // 9. Recent Lab
        if (recentLab != null && recentLab != 'No recent labs uploaded') ...[
          const SectionHeader(title: 'Recent Lab Results'),
          const SizedBox(height: 16),
          AppSectionCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.science, color: AppColors.primary),
              title: Text(recentLab),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/records'),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // 10. Recovery Score & Velocity
        if (recoveryScore != null) ...[
          const SectionHeader(title: 'Recovery Progress'),
          const SizedBox(height: 16),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recovery Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    StatusChip(label: '$recoveryScore%', variant: recoveryScore >= 80 ? StatusVariant.success : StatusVariant.warning),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: recoveryScore / 100,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(recoveryScore >= 80 ? AppColors.success : AppColors.warning),
                    minHeight: 8,
                  ),
                ),
                if (recoveryVelocity.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Velocity: trending ${recoveryVelocity.last > recoveryVelocity.first ? "up" : "down"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildAlertAlert(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vitalTile(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _formatDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}



