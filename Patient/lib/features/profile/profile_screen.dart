// Profile Screen — Premium AI Medical Identity + Personalization Control Center
// UI-only rewrite. All backend logic preserved: profileProvider,
// authProvider.logout(), navigation routes (/onboarding-wizard, /medassist-card,
// /sos, /login).
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_box.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'widgets/premium_profile_hero_card.dart';
import 'widgets/medical_identity_strip.dart';
import 'widgets/ai_personalization_card.dart';
import 'widgets/connected_sources_card.dart';
import 'widgets/emergency_readiness_card.dart';
import 'widgets/privacy_controls_card.dart';
import 'widgets/care_preferences_card.dart';
import 'widgets/secure_account_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncProfile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          asyncProfile.when(
            loading: () => _buildLoading(context, isDark),
            error: (e, _) => _buildError(context, ref, isDark, e),
            data: (profile) =>
                _buildProfile(context, ref, profile, isDark),
          ),
        ],
      ),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context, bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 60),
            ...List.generate(
                5,
                (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShimmerBox(height: 72, borderRadius: 16),
                    )),
          ],
        ),
      ),
    );
  }

  // ── Error ───────────────────────────────────────────────────────────────

  Widget _buildError(
      BuildContext context, WidgetRef ref, bool isDark, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.30)
                  : AppColors.danger),
          const SizedBox(height: 16),
          Text('Failed to load profile',
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => ref.invalidate(profileProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Existing logout logic (preserved) ───────────────────────────────────

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout Session?'),
        content:
            const Text('This will clear local medical caches securely.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              child: const Text('Logout',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
  }

  // ── Main Profile ────────────────────────────────────────────────────────

  Widget _buildProfile(BuildContext context, WidgetRef ref,
      Map<String, dynamic> profile, bool isDark) {
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    // Clinical history data from existing profile
    final medications =
        (profile['current_medications'] as List?)?.cast<String>() ?? [];
    final surgeries =
        (profile['past_surgeries'] as List?)?.cast<String>() ?? [];
    return CustomScrollView(
      slivers: [
        // ═══════════════════════════════════════════════════════════════
        // HEADER
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.30)
                    : Colors.white.withValues(alpha: 0.60),
                padding: EdgeInsets.fromLTRB(
                    16, MediaQuery.paddingOf(context).top + 10, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFF0EA5E9),
                          Color(0xFF6366F1)
                        ]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Medical Identity',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                  letterSpacing: -0.3)),
                          Text('AI personalization control center',
                              style: TextStyle(
                                  fontSize: 10, color: textSub)),
                        ],
                      ),
                    ),
                    // Edit profile
                    GestureDetector(
                      onTap: () => context.push('/onboarding-wizard'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.09)
                              : Colors.white.withValues(alpha: 0.72),
                          border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.white,
                              width: 0.8),
                        ),
                        child: Icon(Icons.edit_rounded,
                            size: 14,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // 1. PROFILE HERO CARD
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: PremiumProfileHeroCard(
              profile: profile,
              onEdit: () => context.push('/onboarding-wizard'),
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // 2. MEDICAL IDENTITY STRIP
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MedicalIdentityStrip(profile: profile),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // 3. CLINICAL HISTORY MEMORY
        // ═══════════════════════════════════════════════════════════════
        if (medications.isNotEmpty || surgeries.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: _SectionLabel(
                icon: Icons.history_rounded,
                label: 'Clinical History Memory',
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                radius: 16,
                blur: 12,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (medications.isNotEmpty)
                      _HistoryRow(
                        icon: Icons.medication_rounded,
                        label: 'Current Medications',
                        items: medications,
                        color: const Color(0xFF3B82F6),
                      ),
                    if (surgeries.isNotEmpty)
                      _HistoryRow(
                        icon: Icons.local_hospital_rounded,
                        label: 'Past Surgeries',
                        items: surgeries,
                        color: const Color(0xFF64748B),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],

        // ═══════════════════════════════════════════════════════════════
        // 4. EMERGENCY READINESS
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: EmergencyReadinessCard(
              profile: profile,
              onOpenSos: () => context.push('/sos'),
              onOpenHealthId: () => context.push('/medassist-card'),
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // 5. AI PERSONALIZATION
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const AiPersonalizationCard(),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // 6. CARE PREFERENCES
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const CarePreferencesCard(),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // 7. CONNECTED SOURCES
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const ConnectedSourcesCard(),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // 8. PRIVACY CONTROLS
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const PrivacyControlsCard(),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // 9. DIGITAL HEALTH ID SHORTCUT
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/medassist-card');
              },
              child: GlassCard(
                radius: 16,
                blur: 12,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFF0EA5E9),
                          Color(0xFF6366F1)
                        ]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.qr_code_rounded,
                          size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Digital Health ID',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary)),
                          Text(
                              'QR card, wallet, doctor scan, PDF export',
                              style: TextStyle(
                                  fontSize: 10, color: textSub)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF0EA5E9)
                                .withValues(alpha: 0.22),
                            width: 0.6),
                      ),
                      child: const Text('Open',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF0EA5E9),
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // 10. ACCOUNT & SECURITY
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SecureAccountCard(
              onLogout: () => _handleLogout(context, ref),
              onDeleteAccount: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Account deletion requires email confirmation.')),
                );
              },
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════════
        // FOOTER
        // ═══════════════════════════════════════════════════════════════
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Center(
              child: Text('MedAssist Engine v2.0.0',
                  style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : AppColors.border,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary)),
      ],
    );
  }
}

// ── Clinical History Row ──────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final Color color;

  const _HistoryRow({
    required this.icon,
    required this.label,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 3,
            children: items.map((item) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.12 : 0.07),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                        color: color.withValues(alpha: 0.22), width: 0.6),
                  ),
                  child: Text(item,
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600)),
                )).toList(),
          ),
        ],
      ),
    );
  }
}
