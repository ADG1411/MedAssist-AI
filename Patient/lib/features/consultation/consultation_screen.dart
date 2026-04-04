<<<<<<< HEAD
=======
// Consultation Screen — fixed Jitsi launch + hangup routing
import 'package:flutter/foundation.dart';
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';

<<<<<<< HEAD
// Web-specific imports handled via conditional compilation
import 'consultation_web.dart'
    if (dart.library.io) 'consultation_native.dart'
=======
// Platform-conditional import
import 'consultation_web.dart' if (dart.library.io) 'consultation_native.dart'
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
    as platform;

class ConsultationScreen extends StatefulWidget {
  final String bookingId;
  final String doctorName;
  final String jitsiRoom;

  const ConsultationScreen({
    super.key,
    required this.bookingId,
    this.doctorName = 'Doctor',
    this.jitsiRoom = 'medassist_default',
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _inCall = false;
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();
    // Web: register the iframe factory immediately
    platform.registerJitsiView(widget.jitsiRoom);
  }

  // ── Join / End ─────────────────────────────────────────────────────────────

  Future<void> _joinMeeting() async {
    setState(() {
      _inCall = true;
      _isLaunching = true;
    });
    HapticFeedback.mediumImpact();

    if (!kIsWeb) {
      // Native: launch Jitsi SDK directly, callback on hangup
      try {
        await platform.launchJitsiMeeting(
          roomId: widget.jitsiRoom,
          displayName: 'MedAssist Patient',
          audioMuted: _isMuted,
          videoMuted: _isVideoOff,
          onConferenceTerminated: _onHangup,
        );
      } catch (e) {
        debugPrint('[Jitsi] launch error: $e');
      }
    }
    if (mounted) setState(() => _isLaunching = false);
  }

  void _onHangup() {
    _endCall();
  }

  Future<void> _endCall() async {
    // Mark booking as completed in Supabase
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({
            'status': 'completed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.bookingId);
    } catch (e) {
      debugPrint('[Booking] complete error: $e');
    }

    if (mounted) {
      context.pushReplacement('/post-consult', extra: widget.bookingId);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_inCall) return _buildCallView();
    return _buildLobby();
  }

  // ── In-call view ───────────────────────────────────────────────────────────

  Widget _buildCallView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Column(
        children: [
          // Top bar
          Container(
            color: const Color(0xFF0D1117),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
<<<<<<< HEAD
                  const Icon(
                    Icons.videocam,
                    color: AppColors.success,
                    size: 20,
                  ),
=======
                  const Icon(Icons.videocam_rounded,
                      color: Color(0xFF10B981), size: 18),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
<<<<<<< HEAD
                          'Video Consultation with ${widget.doctorName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
=======
                          'Consultation with ${widget.doctorName}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                        ),
                        Text(
                          'Room: ${widget.jitsiRoom}',
                          style: TextStyle(
<<<<<<< HEAD
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
=======
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 10),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
<<<<<<< HEAD
                      horizontal: 8,
                      vertical: 4,
                    ),
=======
                        horizontal: 8, vertical: 4),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.30)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
<<<<<<< HEAD
                        Icon(
                          Icons.fiber_manual_record,
                          color: AppColors.success,
                          size: 8,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
=======
                        Icon(Icons.fiber_manual_record,
                            color: Color(0xFF10B981), size: 7),
                        SizedBox(width: 4),
                        Text('LIVE',
                            style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.w800)),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

<<<<<<< HEAD
          // Jitsi video area
          Expanded(child: platform.buildJitsiView(widget.jitsiRoom)),
=======
          // Jitsi view (web: iframe, native: animated overlay)
          Expanded(
            child: platform.buildJitsiView(widget.jitsiRoom),
          ),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e

          // Bottom controls (for web; on native these are in the Jitsi overlay)
          if (kIsWeb)
            Container(
              color: const Color(0xFF0D1117),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControl(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      label: _isMuted ? 'Unmute' : 'Mute',
                      isActive: !_isMuted,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),
                    _buildControl(
                      icon: _isVideoOff
                          ? Icons.videocam_off_rounded
                          : Icons.videocam_rounded,
                      label: _isVideoOff ? 'Video On' : 'Video Off',
                      isActive: !_isVideoOff,
                      onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                    ),
                    _buildControl(
                      icon: Icons.call_end_rounded,
                      label: 'End Call',
                      isActive: false,
                      isDestructive: true,
                      onTap: _endCall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControl({
    required IconData icon,
    required String label,
    required bool isActive,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDestructive
                  ? AppColors.danger
                  : (isActive
<<<<<<< HEAD
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.danger.withValues(alpha: 0.5)),
=======
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.danger.withValues(alpha: 0.50)),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
<<<<<<< HEAD
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
=======
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.60), fontSize: 10)),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
        ],
      ),
    );
  }

  // ── Lobby ──────────────────────────────────────────────────────────────────

  Widget _buildLobby() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: Text('Consultation with ${widget.doctorName}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Doctor avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.softBlue,
                child: Text(
                  widget.doctorName.replaceAll('Dr. ', '').isNotEmpty
                      ? widget.doctorName
                            .replaceAll('Dr. ', '')
                            .substring(0, 1)
                            .toUpperCase()
                      : 'D',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.doctorName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Room: ${widget.jitsiRoom}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'End-to-end encrypted',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Camera preview placeholder
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isVideoOff ? Icons.videocam_off : Icons.person,
                        size: 56,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isVideoOff ? 'Camera Off' : 'Camera Preview',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pre-call controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'mic_lobby',
                    backgroundColor: _isMuted
                        ? AppColors.danger
                        : AppColors.surface,
                    onPressed: () => setState(() => _isMuted = !_isMuted),
                    child: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 24),
                  FloatingActionButton(
                    heroTag: 'cam_lobby',
                    backgroundColor: _isVideoOff
                        ? AppColors.danger
                        : AppColors.surface,
                    onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                    child: Icon(
                      _isVideoOff ? Icons.videocam_off : Icons.videocam,
                      color: _isVideoOff ? Colors.white : AppColors.textPrimary,
=======
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white,
                        border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : AppColors.border,
                            width: 0.5),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 15, color: textPrimary),
>>>>>>> 93734fd3f97e030281539a5b220720560048d38e
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Doctor avatar
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials(widget.doctorName),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(widget.doctorName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.4,
                        )),
                    const SizedBox(height: 6),
                    Text('Video Consultation',
                        style: TextStyle(fontSize: 13, color: textSub)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Room: ${widget.jitsiRoom}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded,
                              size: 11, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text('End-to-end encrypted',
                              style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Camera preview
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : AppColors.border),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isVideoOff
                                  ? Icons.videocam_off_rounded
                                  : Icons.person_rounded,
                              size: 52,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isVideoOff
                                  ? 'Camera Off'
                                  : 'Your camera preview',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mic/Camera toggles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LobbyToggle(
                          icon: _isMuted
                              ? Icons.mic_off_rounded
                              : Icons.mic_rounded,
                          label: _isMuted ? 'Unmute' : 'Mute',
                          isOff: _isMuted,
                          onTap: () =>
                              setState(() => _isMuted = !_isMuted),
                        ),
                        const SizedBox(width: 20),
                        _LobbyToggle(
                          icon: _isVideoOff
                              ? Icons.videocam_off_rounded
                              : Icons.videocam_rounded,
                          label: _isVideoOff ? 'Start Video' : 'Stop Video',
                          isOff: _isVideoOff,
                          onTap: () =>
                              setState(() => _isVideoOff = !_isVideoOff),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Join button
                    GestureDetector(
                      onTap: _isLaunching ? null : _joinMeeting,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 54,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isLaunching
                                ? [
                                    const Color(0xFF6B7280),
                                    const Color(0xFF4B5563)
                                  ]
                                : [
                                    const Color(0xFF2563EB),
                                    const Color(0xFF60A5FA)
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isLaunching
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _isLaunching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.video_call_rounded,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Join Consultation',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    return name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }
}

// ── Lobby Toggle ──────────────────────────────────────────────────────────────

class _LobbyToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOff;
  final VoidCallback onTap;
  const _LobbyToggle(
      {required this.icon,
      required this.label,
      required this.isOff,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOff
                  ? AppColors.danger.withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: Colors.white.withValues(alpha: 0.55))),
        ],
      ),
    );
  }
}
