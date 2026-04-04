// SOS Screen — Fully functional Emergency Dispatch Cockpit
// Connected to SosNotifier via Riverpod — no more stubs.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'sos_provider.dart';
import 'widgets/emergency_dispatch_hero.dart';
import 'widgets/radial_sos_trigger.dart';
import 'widgets/rescue_location_card.dart';
import 'widgets/emergency_medical_packet.dart';
import 'widgets/dispatch_timeline_widget.dart';
import 'widgets/ai_waiting_instruction_card.dart';
import 'widgets/emergency_action_rail.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgPulseController;

  @override
  void initState() {
    super.initState();
    _bgPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgPulseController.dispose();
    super.dispose();
  }

  // ── Actions wired to notifier ─────────────────────────────────────────────

  void _onSosTriggered() {
    HapticFeedback.heavyImpact();
    ref.read(sosProvider.notifier).triggerSos();
  }

  void _cancelSos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Emergency?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text(
            'All contacts will be notified this was a false alarm.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Active',
                  style: TextStyle(color: Color(0xFFEF4444)))),
          TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(sosProvider.notifier).cancelSos();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 10),
                        Text('False alarm — contacts notified'),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                );
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) context.pop();
              },
              child: const Text('Cancel SOS',
                  style: TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sos = ref.watch(sosProvider);
    final notifier = ref.read(sosProvider.notifier);

    final isActive = sos.sosState == SosState.active;
    final isReady = sos.sosState == SosState.ready;
    final emergencyContacts = sos.emergencyContacts;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _bgPulseController,
        builder: (context, _) {
          final pulse = _bgPulseController.value;
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2 + (isActive ? pulse * 0.15 : 0),
                colors: [
                  const Color(0xFFB91C1C),
                  const Color(0xFF7F1D1D),
                  Color.lerp(const Color(0xFF450A0A),
                      const Color(0xFF1A0505), pulse)!,
                ],
              ),
            ),
            child: SafeArea(
              child: isReady
                  ? _buildReadyState(context, sos, notifier)
                  : _buildActiveState(context, sos, notifier, emergencyContacts),
            ),
          );
        },
      ),
    );
  }

  // ── READY STATE ────────────────────────────────────────────────────────────

  Widget _buildReadyState(
    BuildContext context,
    SosFullState sos,
    SosNotifier notifier,
  ) {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 20, color: Colors.white),
                ),
              ),
              const Spacer(),
              // Location chip
              if (sos.position != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gps_fixed_rounded,
                          size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        '${sos.position!.latitude.toStringAsFixed(3)}, '
                        '${sos.position!.longitude.toStringAsFixed(3)}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('Locating…',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const Spacer(flex: 2),

        // Dispatch hero
        EmergencyDispatchHero(
          sosState: sos.sosState,
          nearestHospital: sos.nearestHospital,
          hospitalEta: sos.hospitalEta,
        ),

        const SizedBox(height: 32),

        // Radial trigger
        RadialSosTrigger(
          isActivated: false,
          onTriggered: _onSosTriggered,
        ),

        const Spacer(flex: 2),

        // Action rail (ready state)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: EmergencyActionRail(
            isFlashlightOn: sos.isFlashlightOn,
            isAlarmOn: sos.isAlarmOn,
            onCallFamily: () => notifier.callFirstEmergencyContact(),
            onCallDoctor: () => notifier.callDoctor(),
            onHospitalDirections: () => notifier.openHospitalDirections(),
            onShareQr: () => context.push('/medassist-card'),
            onFlashlight: () => notifier.toggleFlashlight(),
            onAlarm: () => notifier.toggleAlarm(),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ── ACTIVE STATE ───────────────────────────────────────────────────────────

  Widget _buildActiveState(
    BuildContext context,
    SosFullState sos,
    SosNotifier notifier,
    List<Map<String, dynamic>> emergencyContacts,
  ) {
    return CustomScrollView(
      slivers: [
        // Top bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Cancel
                GestureDetector(
                  onTap: _cancelSos,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cancel_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Text('False Alarm',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.80),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Active badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sos.sosState == SosState.active
                        ? const Color(0xFF10B981).withValues(alpha: 0.25)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: sos.sosState == SosState.active
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        sos.sosState == SosState.active
                            ? 'ACTIVE'
                            : 'DISPATCHING',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: sos.sosState == SosState.active
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            letterSpacing: 0.8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Hero
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: EmergencyDispatchHero(
              sosState: sos.sosState,
              contactsNotified: emergencyContacts.length,
              nearestHospital: sos.nearestHospital,
              hospitalEta: sos.hospitalEta,
            ),
          ),
        ),

        // Animated Dispatch Timeline
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DispatchTimelineWidget(
              isActive: true,
              contactCount: emergencyContacts.length,
              dispatchStep: sos.dispatchStep,
              emergencyContacts: emergencyContacts,
            ),
          ),
        ),

        // Rescue location (real GPS)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: RescueLocationCard(
              latitude: sos.position?.latitude ?? 0.0,
              longitude: sos.position?.longitude ?? 0.0,
              address: sos.address,
              nearestHospital: sos.nearestHospital,
              hospitalEta: sos.hospitalEta,
              gpsAccuracy: sos.position?.accuracy,
              isOnline: sos.position != null,
            ),
          ),
        ),

        // Medical packet (from real profile)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: EmergencyMedicalPacket(profile: sos.profile),
          ),
        ),

        // AI waiting instructions
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: AiWaitingInstructionCard(),
          ),
        ),

        // Action rail with live states
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: EmergencyActionRail(
              isFlashlightOn: sos.isFlashlightOn,
              isAlarmOn: sos.isAlarmOn,
              onCallFamily: () => notifier.callFirstEmergencyContact(),
              onCallDoctor: () => notifier.callDoctor(),
              onHospitalDirections: () => notifier.openHospitalDirections(),
              onShareQr: () => context.push('/medassist-card'),
              onFlashlight: () => notifier.toggleFlashlight(),
              onAlarm: () => notifier.toggleAlarm(),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
