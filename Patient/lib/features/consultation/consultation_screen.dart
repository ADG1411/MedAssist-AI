import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';

// Web-specific imports handled via conditional compilation
import 'consultation_web.dart' if (dart.library.io) 'consultation_native.dart' as platform;

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

  @override
  void initState() {
    super.initState();
    platform.registerJitsiView(widget.jitsiRoom);
  }

  void _joinMeeting() {
    if (kIsWeb) {
      setState(() => _inCall = true);
    } else {
      // On native, also just show the iframe-like view for now
      // Full native Jitsi SDK can be added later for Android/iOS
      setState(() => _inCall = true);
    }
  }

  void _endCall() {
    if (mounted) {
      context.pushReplacement('/post-consult', extra: widget.bookingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_inCall) {
      return _buildCallView();
    }
    return _buildLobby();
  }

  Widget _buildCallView() {
    return Scaffold(
      body: Column(
        children: [
          // Top bar
          Container(
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Icon(Icons.videocam, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video Consultation with ${widget.doctorName}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Room: ${widget.jitsiRoom}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record, color: AppColors.success, size: 8),
                        SizedBox(width: 4),
                        Text('LIVE', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Jitsi video area
          Expanded(
            child: platform.buildJitsiView(widget.jitsiRoom),
          ),

          // Bottom controls
          Container(
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallControl(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    isActive: !_isMuted,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _buildCallControl(
                    icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                    label: _isVideoOff ? 'Video On' : 'Video Off',
                    isActive: !_isVideoOff,
                    onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                  ),
                  _buildCallControl(
                    icon: Icons.call_end,
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

  Widget _buildCallControl({
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
                  : (isActive ? Colors.white.withValues(alpha: 0.15) : AppColors.danger.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildLobby() {
    return Scaffold(
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
                      ? widget.doctorName.replaceAll('Dr. ', '').substring(0, 1).toUpperCase()
                      : 'D',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(widget.doctorName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Room: ${widget.jitsiRoom}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text('End-to-end encrypted', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w500)),
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
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
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
                    backgroundColor: _isMuted ? AppColors.danger : AppColors.surface,
                    onPressed: () => setState(() => _isMuted = !_isMuted),
                    child: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: _isMuted ? Colors.white : AppColors.textPrimary),
                  ),
                  const SizedBox(width: 24),
                  FloatingActionButton(
                    heroTag: 'cam_lobby',
                    backgroundColor: _isVideoOff ? AppColors.danger : AppColors.surface,
                    onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                    child: Icon(_isVideoOff ? Icons.videocam_off : Icons.videocam, color: _isVideoOff ? Colors.white : AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              AppButton(
                text: 'Join Consultation',
                icon: const Icon(Icons.video_call, color: Colors.white),
                onPressed: _joinMeeting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
