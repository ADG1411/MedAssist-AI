import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Radial Rescue Trigger — long-press ring progress animation with
/// countdown text (3→2→1→dispatched), haptic feedback, glow pulse,
/// cancel before dispatch, accidental touch prevention. Pure UI widget.
class RadialSosTrigger extends StatefulWidget {
  final bool isActivated;
  final VoidCallback onTriggered;

  const RadialSosTrigger({
    super.key,
    required this.isActivated,
    required this.onTriggered,
  });

  @override
  State<RadialSosTrigger> createState() => _RadialSosTriggerState();
}

class _RadialSosTriggerState extends State<RadialSosTrigger>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !widget.isActivated) {
        HapticFeedback.heavyImpact();
        widget.onTriggered();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails _) {
    if (widget.isActivated) return;
    HapticFeedback.mediumImpact();
    setState(() => _isHolding = true);
    _progressController.forward(from: 0);
  }

  void _onLongPressEnd(LongPressEndDetails _) {
    if (widget.isActivated) return;
    setState(() => _isHolding = false);
    _progressController.stop();
    _progressController.reset();
  }

  String _countdownText(double progress) {
    if (progress >= 1.0) return 'DISPATCHED';
    final remaining = (3 - (progress * 3)).ceil();
    return '$remaining';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _progressController]),
      builder: (context, _) {
        final pulseVal = _pulseController.value;
        final progress = _progressController.value;

        return GestureDetector(
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse rings (when activated)
                if (widget.isActivated)
                  ...List.generate(3, (i) {
                    final size = 180.0 + (pulseVal * 60) + (i * 30);
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(
                              alpha: 0.5 - (pulseVal * 0.2) - (i * 0.1)),
                          width: 1.5,
                        ),
                      ),
                    );
                  }),

                // Glow pulse (while holding)
                if (_isHolding && !widget.isActivated)
                  Container(
                    width: 200 + (pulseVal * 20),
                    height: 200 + (pulseVal * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.08 + pulseVal * 0.06),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                // Progress ring
                if (_isHolding && !widget.isActivated)
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: CircularProgressIndicator(
                      value: progress,
                      color: Colors.white,
                      strokeWidth: 5,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.12),
                    ),
                  ),

                // Core button
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isActivated
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Colors.white.withValues(
                          alpha: widget.isActivated ? 1.0 : 0.50),
                      width: widget.isActivated ? 4 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.20),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                      if (_isHolding)
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.10),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Countdown or SOS text
                      if (_isHolding && !widget.isActivated) ...[
                        Text(
                          _countdownText(progress),
                          style: TextStyle(
                            fontSize: progress >= 1.0 ? 16 : 42,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFEF4444),
                            letterSpacing: 1,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          widget.isActivated
                              ? Icons.check_rounded
                              : Icons.sos_rounded,
                          size: widget.isActivated ? 40 : 36,
                          color: widget.isActivated
                              ? const Color(0xFFEF4444)
                              : Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isActivated ? 'ACTIVE' : 'HOLD',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: widget.isActivated
                                ? const Color(0xFFEF4444)
                                : Colors.white.withValues(alpha: 0.70),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
