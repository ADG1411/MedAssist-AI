// SOS Screen — Premium Emergency Dispatch Cockpit
// UI-only rewrite. All existing backend logic patterns preserved:
// animation controller, hold-to-trigger, _triggerSos, context.pop().
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/emergency_dispatch_hero.dart';
import 'widgets/radial_sos_trigger.dart';
import 'widgets/rescue_location_card.dart';
import 'widgets/emergency_medical_packet.dart';
import 'widgets/dispatch_timeline_widget.dart';
import 'widgets/ai_waiting_instruction_card.dart';
import 'widgets/emergency_action_rail.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgPulseController;
  SosState _sosState = SosState.ready;
  bool _isCancelled = false;

  // Mock profile for medical packet (in real app, from provider)
  final Map<String, dynamic> _mockProfile = const {
    'name': 'Rahul',
    'bloodGroup': 'O+',
    'age': 32,
    'gender': 'Male',
    'weight_kg': '72',
    'allergies': ['Penicillin', 'Peanuts'],
    'chronicConditions': ['GERD'],
    'current_medications': [],
    'insurance': '',
    'emergency_contacts': [
      {'name': 'Mom', 'phone': '+91 98765 43210'},
    ],
  };

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

  // ── Existing trigger logic (preserved pattern) ──────────────────────────

  void _onSosTriggered() {
    setState(() => _sosState = SosState.dispatching);
    HapticFeedback.heavyImpact();

    // Simulate dispatch sequence
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _isCancelled) return;
      setState(() => _sosState = SosState.active);
      _triggerSos();
    });
  }

  void _triggerSos() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'Hospital Notified — Civil Hospital, 1.2km',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 5),
        ),
      );
    });
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
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isCancelled = true;
                  _sosState = SosState.cancelled;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('False alarm — contacts notified')),
                );
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) context.pop();
                });
              },
              child: const Text('Cancel SOS',
                  style: TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _sosState == SosState.active;
    final isReady = _sosState == SosState.ready;
    final emergencyContacts =
        (_mockProfile['emergency_contacts'] as List?) ?? [];

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
                  ? _buildReadyState(context)
                  : _buildActiveState(context, emergencyContacts),
            ),
          );
        },
      ),
    );
  }

  // ── READY STATE — centered trigger ──────────────────────────────────────

  Widget _buildReadyState(BuildContext context) {
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
              // Voice SOS
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Listening for voice command…')),
                  );
                },
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
                      const Icon(Icons.mic_rounded,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 5),
                      Text('Voice SOS',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.80),
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 2),

        // Dispatch hero
        EmergencyDispatchHero(
          sosState: _sosState,
          nearestHospital: 'Civil Hospital',
          hospitalEta: '4 mins',
        ),

        const SizedBox(height: 32),

        // Radial trigger
        RadialSosTrigger(
          isActivated: false,
          onTriggered: _onSosTriggered,
        ),

        const Spacer(flex: 2),

        // Action rail
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: EmergencyActionRail(
            onCallFamily: () => _snack('Calling family…'),
            onCallDoctor: () => _snack('Calling doctor…'),
            onHospitalDirections: () => _snack('Opening directions…'),
            onShareQr: () => context.push('/medassist-card'),
            onFlashlight: () => _snack('Flashlight toggled'),
            onAlarm: () => _snack('Alarm sounding…'),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // ── ACTIVE STATE — scrollable dispatch cockpit ──────────────────────────

  Widget _buildActiveState(
      BuildContext context, List<dynamic> emergencyContacts) {
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
                    color: _sosState == SosState.active
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
                          color: _sosState == SosState.active
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _sosState == SosState.active
                            ? 'ACTIVE'
                            : 'DISPATCHING',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _sosState == SosState.active
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
              sosState: _sosState,
              contactsNotified: emergencyContacts.length,
              nearestHospital: 'Civil Hospital',
              hospitalEta: '4 mins',
            ),
          ),
        ),

        // Dispatch Timeline
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DispatchTimelineWidget(
              isActive: true,
              contactCount: emergencyContacts.length,
            ),
          ),
        ),

        // Rescue location
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: RescueLocationCard(
              latitude: 23.0225,
              longitude: 72.5714,
              address: 'Near Paldi Cross Rd, Ahmedabad',
              nearestHospital: 'Civil Hospital',
              hospitalEta: '4 mins',
              gpsAccuracy: 12,
              isOnline: true,
            ),
          ),
        ),

        // Medical packet
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: EmergencyMedicalPacket(profile: _mockProfile),
          ),
        ),

        // AI waiting instructions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: const AiWaitingInstructionCard(),
          ),
        ),

        // Action rail
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: EmergencyActionRail(
              onCallFamily: () => _snack('Calling family…'),
              onCallDoctor: () => _snack('Calling doctor…'),
              onHospitalDirections: () => _snack('Opening directions…'),
              onShareQr: () => context.push('/medassist-card'),
              onFlashlight: () => _snack('Flashlight toggled'),
              onAlarm: () => _snack('Alarm sounding…'),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

