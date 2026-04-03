import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme/app_colors.dart';

class VoiceInputSheet extends StatefulWidget {
  final ValueChanged<String> onResult;

  const VoiceInputSheet({super.key, required this.onResult});

  /// Show the voice input bottom sheet
  static Future<void> show(BuildContext context, {required ValueChanged<String> onResult}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceInputSheet(onResult: onResult),
    );
  }

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet> with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _recognizedText = '';
  String _statusText = 'Tap mic to start';
  double _confidence = 0.0;

  // Pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Wave animation
  late AnimationController _waveController;

  // Glow animation
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initSpeech();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initSpeech() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: _onStatus,
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');
          setState(() {
            if (error.errorMsg == 'error_permission' || error.errorMsg == 'error_audio_error') {
              _statusText = 'Microphone permission denied.\nPlease enable it in Settings.';
            } else {
              _statusText = 'Error: ${error.errorMsg}';
            }
            _isListening = false;
          });
          _stopAnimations();
        },
      );
      setState(() {
        _statusText = _isAvailable ? 'Tap mic to speak' : 'Microphone permission required.\nPlease grant access and try again.';
      });
      // Auto-start listening
      if (_isAvailable) {
        _startListening();
      }
    } catch (e) {
      debugPrint('Speech init error: $e');
      setState(() {
        _statusText = 'Microphone not available.\nCheck permissions in Settings.';
        _isAvailable = false;
      });
    }
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (_recognizedText.isNotEmpty && _isListening) {
        // Auto-submit after speech ends
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _recognizedText.isNotEmpty) {
            _submitResult();
          }
        });
      }
      setState(() => _isListening = false);
      _stopAnimations();
    }
  }

  void _startListening() async {
    if (!_isAvailable) return;

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _statusText = 'Listening...';
    });
    _startAnimations();

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          _confidence = result.confidence;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _statusText = _recognizedText.isNotEmpty ? 'Tap send or speak again' : 'Tap mic to speak';
    });
    _stopAnimations();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
    _glowController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _pulseController.stop();
    _waveController.stop();
    _glowController.stop();
    _pulseController.reset();
    _glowController.reset();
  }

  void _submitResult() {
    if (_recognizedText.isNotEmpty) {
      widget.onResult(_recognizedText);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              _isListening ? 'Listening...' : 'Voice Input',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _statusText,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Animated Mic Button with waves
            SizedBox(
              height: 160,
              width: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sound waves (outer rings)
                  if (_isListening) ...[
                    _buildWaveRing(0, 140),
                    _buildWaveRing(0.33, 120),
                    _buildWaveRing(0.66, 100),
                  ],

                  // Glow
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 90 + (_isListening ? _glowAnimation.value * 15 : 0),
                        height: 90 + (_isListening ? _glowAnimation.value * 15 : 0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3 * _glowAnimation.value),
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                  ),
                                ]
                              : [],
                        ),
                      );
                    },
                  ),

                  // Main mic button
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final scale = _isListening ? _pulseAnimation.value : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: GestureDetector(
                          onTap: _isListening ? _stopListening : _startListening,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _isListening
                                    ? [AppColors.danger, AppColors.danger.withValues(alpha: 0.7)]
                                    : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening ? AppColors.danger : AppColors.primary).withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recognized text
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isListening
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _recognizedText.isNotEmpty ? _recognizedText : 'Your words will appear here...',
                    style: TextStyle(
                      fontSize: 16,
                      color: _recognizedText.isNotEmpty ? null : AppColors.textSecondary,
                      fontWeight: _recognizedText.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_confidence > 0 && _recognizedText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          'Confidence: ${(_confidence * 100).toInt()}%',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            if (_recognizedText.isNotEmpty && !_isListening)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _recognizedText = '';
                          _statusText = 'Tap mic to speak';
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _submitResult,
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Send to AI'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveRing(double delayFraction, double size) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final progress = ((_waveController.value + delayFraction) % 1.0);
        final opacity = (1.0 - progress).clamp(0.0, 0.5);
        final scale = 0.6 + progress * 0.4;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

