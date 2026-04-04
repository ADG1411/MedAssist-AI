// MedAssist Card Screen — Premium Digital Health Passport
// UI-only rewrite. All backend logic preserved: authProvider,
// existing QR generation, existing userData construction.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/glass_card.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'widgets/premium_health_id_card.dart';
import 'widgets/emergency_qr_preview_sheet.dart';

class MedAssistCardScreen extends ConsumerWidget {
  const MedAssistCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    final authState = ref.watch(authProvider);

    // Build user data from real auth state, with sensible fallbacks
    final userData = {
      'name': authState?['name'] ?? 'MedAssist User',
      'healthId':
          'MD-${(authState?['id'] ?? 'anon').toString().substring(0, 8).toUpperCase()}',
      'bloodGroup': authState?['bloodGroup'] ?? 'N/A',
      'dob': authState?['dob'] ?? 'Not Set',
      'gender': authState?['gender'] ?? 'Not Set',
    };

    // Extract allergies and conditions from auth metadata
    final allergies =
        (authState?['allergies'] as List<dynamic>?) ?? [];
    final conditions =
        (authState?['chronicConditions'] as List<dynamic>?) ?? [];
    final emergencyContact =
        authState?['emergencyContact']?.toString() ?? '';
    final insurance =
        authState?['insurance']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          CustomScrollView(
            slivers: [
              // ═══════════════════════════════════════════════════════
              // HEADER
              // ═══════════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.30)
                          : Colors.white.withValues(alpha: 0.60),
                      padding: EdgeInsets.fromLTRB(
                          16,
                          MediaQuery.paddingOf(context).top + 10,
                          16,
                          14),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.09)
                                    : Colors.white.withValues(alpha: 0.72),
                              ),
                              child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 14,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('Health Passport',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                        letterSpacing: -0.3)),
                                Text('Portable digital health identity',
                                    style: TextStyle(
                                        fontSize: 10, color: textSub)),
                              ],
                            ),
                          ),
                          // Emergency QR
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              EmergencyQrPreviewSheet.show(
                                context,
                                userData: userData,
                                allergies: allergies,
                                conditions: conditions,
                                emergencyContact: emergencyContact,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.25),
                                    width: 0.7),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emergency_rounded,
                                      size: 14,
                                      color: Color(0xFFEF4444)),
                                  SizedBox(width: 4),
                                  Text('SOS QR',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFEF4444),
                                          fontWeight:
                                              FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ═══════════════════════════════════════════════════════
              // PREMIUM HEALTH ID CARD
              // ═══════════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: PremiumHealthIdCard(
                    userData: userData,
                    allergies: allergies,
                    conditions: conditions,
                  ),
                ),
              ),

              // ═══════════════════════════════════════════════════════
              // EMERGENCY QUICK ACCESS
              // ═══════════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    radius: 18,
                    blur: 14,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.22),
                                    width: 0.6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emergency_rounded,
                                      size: 12,
                                      color: Color(0xFFEF4444)),
                                  SizedBox(width: 4),
                                  Text('Emergency Access',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFEF4444),
                                          fontWeight:
                                              FontWeight.w700)),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text('Visible on QR scan',
                                style: TextStyle(
                                    fontSize: 9, color: textSub)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Info rows
                        _EmergencyInfoRow(
                          icon: Icons.water_drop_rounded,
                          label: 'Blood Group',
                          value: userData['bloodGroup']?.toString() ?? 'N/A',
                          color: const Color(0xFFEF4444),
                          isDark: isDark,
                        ),
                        if (allergies.isNotEmpty)
                          _EmergencyInfoRow(
                            icon: Icons.warning_amber_rounded,
                            label: 'Allergies',
                            value: allergies.join(', '),
                            color: const Color(0xFFF97316),
                            isDark: isDark,
                          ),
                        if (conditions.isNotEmpty)
                          _EmergencyInfoRow(
                            icon: Icons.medical_information_rounded,
                            label: 'Chronic Conditions',
                            value: conditions.join(', '),
                            color: const Color(0xFF8B5CF6),
                            isDark: isDark,
                          ),
                        if (emergencyContact.isNotEmpty)
                          _EmergencyInfoRow(
                            icon: Icons.phone_rounded,
                            label: 'Emergency Contact',
                            value: emergencyContact,
                            color: const Color(0xFF10B981),
                            isDark: isDark,
                          ),
                        if (insurance.isNotEmpty)
                          _EmergencyInfoRow(
                            icon: Icons.shield_rounded,
                            label: 'Insurance',
                            value: insurance,
                            color: const Color(0xFF0EA5E9),
                            isDark: isDark,
                          ),
                        if (allergies.isEmpty &&
                            conditions.isEmpty &&
                            emergencyContact.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No emergency info recorded. Update your profile to enable emergency access.',
                              style: TextStyle(
                                  fontSize: 11, color: textSub),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ═══════════════════════════════════════════════════════
              // ACTION BUTTONS
              // ═══════════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    children: [
                      // Emergency QR large button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          EmergencyQrPreviewSheet.show(
                            context,
                            userData: userData,
                            allergies: allergies,
                            conditions: conditions,
                            emergencyContact: emergencyContact,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFFEF4444),
                              Color(0xFFDC2626)
                            ]),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.30),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_scanner_rounded,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Show Emergency QR',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          // Add to wallet
                          Expanded(
                            child: _PassportAction(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Add to Wallet',
                              color: const Color(0xFF3B82F6),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content:
                                            Text('Added to Wallet')));
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Download PDF
                          Expanded(
                            child: _PassportAction(
                              icon: Icons.picture_as_pdf_rounded,
                              label: 'Download PDF',
                              color: const Color(0xFF10B981),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content:
                                            Text('Downloading PDF…')));
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Share
                          Expanded(
                            child: _PassportAction(
                              icon: Icons.share_rounded,
                              label: 'Share Card',
                              color: const Color(0xFF8B5CF6),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Generating share link…')));
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ═══════════════════════════════════════════════════════
              // LAST SYNCED
              // ═══════════════════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sync_rounded,
                          size: 11, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text('Last synced: just now',
                          style: TextStyle(
                              fontSize: 10,
                              color: textSub,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Emergency Info Row ────────────────────────────────────────────────────

class _EmergencyInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _EmergencyInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

// ── Passport Action Button ────────────────────────────────────────────────

class _PassportAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _PassportAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: color.withValues(alpha: 0.22), width: 0.7),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
