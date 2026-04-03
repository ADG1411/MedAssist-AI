import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../../core/theme/app_colors.dart';

class ConsultationScreen extends StatefulWidget {
  final String bookingId;

  const ConsultationScreen({super.key, required this.bookingId});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  final _jitsiMeetPlugin = JitsiMeet();

  void _joinMeeting() async {
    var options = JitsiMeetConferenceOptions(
      room: 'medassist_app_b_${widget.bookingId}',
      serverURL: 'https://meet.jit.si',
      configOverrides: {
        "startWithAudioMuted": _isMuted,
        "startWithVideoMuted": _isVideoOff,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: "MedAssist Patient",
      ),
    );

    var listener = JitsiMeetEventListener(
      conferenceTerminated: (url, error) {
        debugPrint("Jitsi: conferenceTerminated: url: $url, error: $error");
        if (mounted) {
          context.pushReplacement('/post-consult', extra: widget.bookingId);
        }
      },
    );

    await _jitsiMeetPlugin.join(options, listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultation Lobby')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Icon(
                    _isVideoOff ? Icons.videocam_off : Icons.person,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'mic',
                    backgroundColor: _isMuted ? AppColors.danger : AppColors.surface,
                    onPressed: () => setState(() => _isMuted = !_isMuted),
                    child: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: _isMuted ? Colors.white : AppColors.textPrimary),
                  ),
                  const SizedBox(width: 24),
                  FloatingActionButton(
                    heroTag: 'cam',
                    backgroundColor: _isVideoOff ? AppColors.danger : AppColors.surface,
                    onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                    child: Icon(_isVideoOff ? Icons.videocam_off : Icons.videocam, color: _isVideoOff ? Colors.white : AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _joinMeeting,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Join Consultation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
