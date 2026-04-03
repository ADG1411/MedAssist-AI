import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isActivated = false;
  bool _isDialing = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_isActivated) return;
    setState(() => _isDialing = true);
    _simulateProgress();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_isActivated) return;
    setState(() {
       _isDialing = false;
       _progress = 0;
    });
  }

  Future<void> _simulateProgress() async {
    while (_isDialing && _progress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      if (_isDialing) {
        setState(() {
          _progress += 0.05;
        });
      }
    }
    
    if (_progress >= 1.0 && !_isActivated) {
      setState(() => _isActivated = true);
      _triggerSos();
    }
  }

  void _triggerSos() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Hospital Notified  City Hospital, 1.2km', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 5),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.danger,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            const Spacer(),
            
            // SOS Main Context
            Text(
              _isActivated ? 'BROADCASTING' : 'EMERGENCY SOS',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            Text(
              _isActivated 
                ? 'Sending your location to nearest responders...' 
                : 'Press and hold for 1.5 seconds to dispatch emergency units.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            
            const SizedBox(height: 64),
            
            // Giant SOS Button
            GestureDetector(
              onLongPressStart: _onLongPressStart,
              onLongPressEnd: _onLongPressEnd,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse rings
                      if (_isActivated)
                        ...List.generate(3, (index) {
                          return Container(
                            width: 160 + (_controller.value * 120) + (index * 40),
                            height: 160 + (_controller.value * 120) + (index * 40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8 - (_controller.value * 0.4) - (index * 0.1)),
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      
                      // Progress Ring
                      if (_isDialing && !_isActivated)
                        SizedBox(
                          width: 190,
                          height: 190,
                          child: CircularProgressIndicator(
                            value: _progress,
                            color: Colors.white,
                            strokeWidth: 8,
                          ),
                        ),
                        
                      // Core Button
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: _isActivated ? Colors.white : AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'SOS',
                            style: TextStyle(
                              color: _isActivated ? AppColors.danger : Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const Spacer(),
            
            // Secondary Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSecondaryAction(Icons.mic, 'Voice SOS'),
                  _buildSecondaryAction(Icons.phone, 'Call Contacts'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

