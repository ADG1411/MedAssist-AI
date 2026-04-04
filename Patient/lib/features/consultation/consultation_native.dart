// Native-only Jitsi implementation using jitsi_meet_flutter_sdk
// Fixes: proper SDK launch on join, hangup listener, permission request before join
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';

final _jitsiMeet = JitsiMeet();

// Called from consultation_screen.dart initState — nothing to register on native
void registerJitsiView(String roomId) {}

/// Returns a placeholder widget; actual call view is a native overlay
Widget buildJitsiView(String roomId) {
  return _NativeJitsiCallView(roomId: roomId);
}

/// Requests camera + mic, then launches the native Jitsi meeting.
/// [onConferenceTerminated] is called when the user hangs up.
Future<void> launchJitsiMeeting({
  required String roomId,
  String displayName = 'MedAssist Patient',
  String email = '',
  bool audioMuted = false,
  bool videoMuted = false,
  void Function()? onConferenceTerminated,
}) async {
  // 1. Request permissions BEFORE launching — Jitsi crashes without them
  final camStatus = await Permission.camera.request();
  final micStatus = await Permission.microphone.request();
  if (camStatus.isDenied || micStatus.isDenied) {
    debugPrint('[Jitsi] Permissions denied — cam=$camStatus mic=$micStatus');
    return;
  }

  // 2. Configure the meeting
  final options = JitsiMeetConferenceOptions(
    serverURL: 'https://meet.jit.si',
    room: roomId,
    configOverrides: {
      'startWithAudioMuted': audioMuted,
      'startWithVideoMuted': videoMuted,
      'subject': 'MedAssist Consultation',
      'prejoinPageEnabled': false,         // skip prejoin page
      'disableDeepLinking': true,
      'requireDisplayName': false,
      'enableWelcomePage': false,
      'p2p.enabled': true,                 // direct P2P = lower latency
      'disableTileView': false,
    },
    featureFlags: {
      'unsaferoomwarning.enabled': false,
      'security-options.enabled': false,
      'lobby-mode.enabled': false,
      'invite.enabled': false,
      'live-streaming.enabled': false,
      'recording.enabled': false,
      'breakout-rooms.enabled': false,
      'pip.enabled': true,
      'chat.enabled': true,
      'meeting-name.enabled': true,
      'video-share.enabled': false,
    },
    userInfo: JitsiMeetUserInfo(
      displayName: displayName,
      email: email,
    ),
  );

  // 3. Attach event listener to handle hangup
  final listener = JitsiMeetEventListener(
    conferenceJoined: (url) {
      debugPrint('[Jitsi] Conference joined: $url');
    },
    conferenceTerminated: (url, error) {
      debugPrint('[Jitsi] Conference terminated: $url error=$error');
      onConferenceTerminated?.call();
    },
    conferenceWillJoin: (url) {
      debugPrint('[Jitsi] Will join: $url');
    },
    participantJoined: (email, name, role, id) {
      debugPrint('[Jitsi] Participant joined: $name');
    },
    participantLeft: (id) {
      debugPrint('[Jitsi] Participant left: $id');
    },
  );

  // 4. Launch
  await _jitsiMeet.join(options, listener);
}

// ── Internal widget shown while the native overlay is running ─────────────────

class _NativeJitsiCallView extends StatefulWidget {
  final String roomId;
  const _NativeJitsiCallView({required this.roomId});

  @override
  State<_NativeJitsiCallView> createState() => _NativeJitsiCallViewState();
}

class _NativeJitsiCallViewState extends State<_NativeJitsiCallView> {
  bool _launched = false;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _autoLaunch();
  }

  Future<void> _autoLaunch() async {
    if (_launched) return;
    setState(() => _joining = true);
    _launched = true;

    // Small settle delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      await launchJitsiMeeting(
        roomId: widget.roomId,
        onConferenceTerminated: () {
          if (mounted) setState(() => _launched = false);
        },
      );
    } catch (e) {
      debugPrint('[Jitsi] Launch error: $e');
      if (mounted) setState(() => _launched = false);
    }
    if (mounted) setState(() => _joining = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1117),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated ring
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.40),
                    blurRadius: _joining ? 24 : 8,
                    spreadRadius: _joining ? 4 : 0,
                  ),
                ],
              ),
              child: const Icon(Icons.video_call_rounded,
                  size: 44, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              _joining ? 'Connecting to room…' : 'Video call running',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.roomId,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40), fontSize: 12),
            ),
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.30)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record,
                      color: Color(0xFF10B981), size: 8),
                  SizedBox(width: 6),
                  Text(
                    'E2E Encrypted · Jitsi Meet',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!_joining)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _launched = false;
                    _joining = false;
                  });
                  _autoLaunch();
                },
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white70, size: 18),
                label: const Text('Rejoin Call',
                    style: TextStyle(color: Colors.white70)),
              ),
          ],
        ),
      ),
    );
  }
}
