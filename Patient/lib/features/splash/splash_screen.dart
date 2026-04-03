import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _ecgPath;
  late Animation<double> _textFade;
  late Animation<double> _bottomFade;

  @override
  void initState() {
    super.initState();

    // Immersive status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.0, 0.35, curve: Curves.easeOut)),
    );

    _ecgPath = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.25, 0.75, curve: Curves.easeInOut)),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );

    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _mainController.forward();

    // Navigate after delay (preserved)
    Future.delayed(
        const Duration(milliseconds: AppConstants.longMockDelayMs), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle radial glow behind logo
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Center(
                    child: Container(
                      width: 280 + (_pulseController.value * 40),
                      height: 280 + (_pulseController.value * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF3B82F6)
                                .withValues(alpha: 0.06 + _pulseController.value * 0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, _) {
                  return Column(
                    children: [
                      const Spacer(flex: 3),

                      // Logo with scale + fade + glow
                      Opacity(
                        opacity: _logoFade.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.20),
                                  blurRadius: 32,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: SvgPicture.asset(
                                'assets/images/logo.svg',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // App name
                      Opacity(
                        opacity: _textFade.value,
                        child: Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Tagline
                      Opacity(
                        opacity: _textFade.value,
                        child: Text(
                          'Your AI-Powered Health Companion',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.45),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ECG heartbeat line
                      SizedBox(
                        width: 220,
                        height: 50,
                        child: CustomPaint(
                          painter: _EcgPainter(_ecgPath.value),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Loading text
                      Opacity(
                        opacity: _bottomFade.value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color:
                                    Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Initializing health engine…',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.white.withValues(alpha: 0.35),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Bottom version + AI badge
                      Opacity(
                        opacity: _bottomFade.value,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1)
                                        .withValues(alpha: 0.20),
                                    const Color(0xFF3B82F6)
                                        .withValues(alpha: 0.20),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF6366F1)
                                        .withValues(alpha: 0.20),
                                    width: 0.6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome,
                                      size: 11,
                                      color: Colors.white
                                          .withValues(alpha: 0.60)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Powered by Clinical AI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                          .withValues(alpha: 0.50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'v2.0.0',
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    Colors.white.withValues(alpha: 0.18),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ECG Heartbeat Painter ─────────────────────────────────────────────────

class _EcgPainter extends CustomPainter {
  final double progress;

  _EcgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;

    // Glow line
    final glowPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.15)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Main line
    final mainPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.70)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, h * 0.5)
      ..lineTo(w * 0.15, h * 0.5)
      ..lineTo(w * 0.22, h * 0.5)
      ..lineTo(w * 0.28, h * 0.15)
      ..lineTo(w * 0.35, h * 0.85)
      ..lineTo(w * 0.42, h * 0.30)
      ..lineTo(w * 0.48, h * 0.5)
      ..lineTo(w * 0.58, h * 0.5)
      ..lineTo(w * 0.63, h * 0.38)
      ..lineTo(w * 0.68, h * 0.62)
      ..lineTo(w * 0.73, h * 0.5)
      ..lineTo(w * 0.85, h * 0.5)
      ..lineTo(w, h * 0.5);

    for (var metric in path.computeMetrics()) {
      final extractPath =
          metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, glowPaint);
      canvas.drawPath(extractPath, mainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

