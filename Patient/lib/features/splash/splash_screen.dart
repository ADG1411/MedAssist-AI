import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pathAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pathAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
    
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate after 2500ms
    Future.delayed(const Duration(milliseconds: AppConstants.longMockDelayMs), () {
      if (mounted) {
        // We'll mock that it's the first launch
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed to white to fit most multi-colored brand SVGs
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Real Logo
            ScaleTransition(
              scale: _scaleAnim,
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                width: 140,
                height: 140,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),
            // Animated ECG Line
            AnimatedBuilder(
              animation: _pathAnim,
              builder: (context, _) {
                return SizedBox(
                  width: 200,
                  height: 60,
                  child: CustomPaint(
                    painter: _EcgPainter(_pathAnim.value),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Fading Text
            AnimatedBuilder(
              animation: _fadeAnim,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnim.value,
                  child: child,
                );
              },
              child: const Text(
                'Loading your health data...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double progress;

  _EcgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();
    double h = size.height;
    double w = size.width;

    path.moveTo(0, h / 2);
    path.lineTo(w * 0.2, h / 2);
    path.lineTo(w * 0.3, h * 0.2);
    path.lineTo(w * 0.4, h * 0.8);
    path.lineTo(w * 0.5, h / 2);
    path.lineTo(w * 0.6, h / 2);
    path.lineTo(w * 0.7, h * 0.4);
    path.lineTo(w * 0.8, h / 2);
    path.lineTo(w, h / 2);

    // Render path up to progress length using path metrics
    for (var metric in path.computeMetrics()) {
      var extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

