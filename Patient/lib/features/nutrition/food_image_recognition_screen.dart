/// Food Image Recognition Screen — FatSecret AI
/// Pick from camera or gallery → animated scan → results with nutrition
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'models/intake_entry.dart';
import 'services/fatsecret_service.dart';
import 'package:image_picker/image_picker.dart';

class FoodImageRecognitionScreen extends ConsumerStatefulWidget {
  final MealType? initialMealType;
  const FoodImageRecognitionScreen({super.key, this.initialMealType});

  @override
  ConsumerState<FoodImageRecognitionScreen> createState() => _FoodImageRecognitionScreenState();
}

class _FoodImageRecognitionScreenState extends ConsumerState<FoodImageRecognitionScreen>
    with TickerProviderStateMixin {
  final _fatSecretService = FatSecretService();
  final _imagePicker = ImagePicker();

  // State
  Uint8List? _imageBytes;
  bool _isScanning = false;
  bool _hasError = false;
  String _errorMessage = '';
  FoodRecognitionResult? _result;

  // Animations
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _resultSlideController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _resultSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    _resultSlideController.dispose();
    _fatSecretService.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85, // Compress to stay under 1MB
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _result = null;
          _hasError = false;
        });
        _startRecognition();
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  Future<void> _startRecognition() async {
    if (_imageBytes == null) return;

    setState(() {
      _isScanning = true;
      _hasError = false;
      _result = null;
    });

    _scanLineController.repeat();
    _pulseController.repeat(reverse: true);

    try {
      final result = await _fatSecretService.recognizeImage(_imageBytes!);

      if (mounted) {
        setState(() {
          _result = result;
          _isScanning = false;
        });
        _scanLineController.stop();
        _pulseController.stop();
        _resultSlideController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _hasError = true;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        _scanLineController.stop();
        _pulseController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Dark immersive background for scanner feel
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D1117), Color(0xFF161B22)],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Glass header ────────────────────────────────────────
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.10),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    width: 0.8),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('AI Food Scanner',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.3)),
                                Text(
                                  widget.initialMealType != null
                                      ? 'Adding to ${widget.initialMealType!.label}'
                                      : 'Photo → instant nutrition',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.50)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome,
                                    size: 10, color: Colors.white),
                                SizedBox(width: 4),
                                Text('AI Powered',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Image preview ────────────────────────────────────────
                Expanded(
                  flex: _result != null ? 2 : 3,
                  child: _buildImageArea(),
                ),

                // ── Results ──────────────────────────────────────────────
                if (_result != null) Expanded(flex: 3, child: _buildResults()),

                // ── Bottom actions ────────────────────────────────────────
                if (_result == null && !_isScanning) _buildBottomActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isScanning
              ? const Color(0xFF58D68D).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: _isScanning
            ? [
                BoxShadow(
                  color: const Color(0xFF58D68D).withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or placeholder
            if (_imageBytes != null)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isScanning ? _pulseAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.cover,
                ),
              )
            else
              _buildPlaceholder(),

            // Scanning overlay
            if (_isScanning) _buildScanOverlay(),

            // Scanning status badge
            if (_isScanning)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF58D68D).withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58D68D)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Analyzing food...',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Error overlay
            if (_hasError)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _startRecognition,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF58D68D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF58D68D),
                  Color(0xFF3498DB),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF58D68D).withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 22),
          const Text(
            'Point camera at your food',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'AI detects food and calculates full nutrition instantly',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50), fontSize: 13),
          ),
          const SizedBox(height: 20),
          // Feature pills
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _FeaturePill('🍚 Indian foods'),
              _FeaturePill('📦 Packaged items'),
              _FeaturePill('🥗 Mixed dishes'),
              _FeaturePill('🏪 Restaurant food'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _FeaturePill(String text) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.12), width: 0.7),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.70),
                fontWeight: FontWeight.w500)),
      );

  Widget _buildScanOverlay() {
    return AnimatedBuilder(
      animation: _scanLineAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanLinePainter(
            progress: _scanLineAnimation.value,
            color: const Color(0xFF58D68D),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, 20 + MediaQuery.paddingOf(context).bottom),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.40),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.08), width: 0.7),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xFF3498DB),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _pickImage(fromCamera: false);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFF58D68D),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _pickImage(fromCamera: true);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Supports JPG, PNG, WebP  •  AI identifies multiple foods at once',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.30),
                    fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final result = _result!;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
          parent: _resultSlideController, curve: Curves.easeOutCubic)),
      child: ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08), width: 0.7),
            ),
            child: Column(
              children: [
                // Handle + header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 38, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF58D68D)
                                  .withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF58D68D)
                                      .withValues(alpha: 0.30),
                                  width: 0.7),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    size: 12,
                                    color: Color(0xFF58D68D)),
                                const SizedBox(width: 5),
                                Text(
                                  '${result.foods.length} Foods Detected',
                                  style: const TextStyle(
                                      color: Color(0xFF58D68D),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${result.totalCalories} kcal total',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _pickImage(fromCamera: false);
                            },
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                              child: const Icon(Icons.refresh_rounded,
                                  size: 16,
                                  color: Color(0xFF58D68D)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Macro strip
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF58D68D).withValues(alpha: 0.12),
                        const Color(0xFF3498DB).withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF58D68D).withValues(alpha: 0.18),
                        width: 0.7),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MacroChip(
                          label: 'Calories',
                          value: '${result.totalCalories}',
                          unit: 'kcal',
                          color: const Color(0xFFF39C12)),
                      _MacroChip(
                          label: 'Protein',
                          value: result.totalProtein.toStringAsFixed(1),
                          unit: 'g',
                          color: const Color(0xFF58D68D)),
                      _MacroChip(
                          label: 'Carbs',
                          value: result.totalCarbs.toStringAsFixed(1),
                          unit: 'g',
                          color: const Color(0xFF3498DB)),
                      _MacroChip(
                          label: 'Fat',
                          value: result.totalFat.toStringAsFixed(1),
                          unit: 'g',
                          color: const Color(0xFFE74C3C)),
                    ],
                  ),
                ),

                // Food cards list
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: result.foods.length,
                    itemBuilder: (context, i) {
                      final food = result.foods[i];
                      return _FoodResultCard(
                        food: food,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/nutrition/food-detail', extra: {
                            'meal': food.toMealEntity(),
                            'mealType':
                                widget.initialMealType ?? MealType.snack,
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-Widgets ──────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0.10)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: color.withValues(alpha: 0.28), width: 0.8),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 12),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 7),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
        ),
      );
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 2),
        Text(unit, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
      ],
    );
  }
}

class _FoodResultCard extends StatelessWidget {
  final RecognizedFood food;
  final VoidCallback onTap;

  const _FoodResultCard({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10),
              width: 0.7),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF58D68D), Color(0xFF3498DB)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${food.servingDescription}  •  ${food.totalMetricAmount.toStringAsFixed(0)}${food.metricUnit}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MiniBadge('P ${food.protein.toStringAsFixed(0)}g',
                          const Color(0xFF58D68D)),
                      const SizedBox(width: 4),
                      _MiniBadge('C ${food.carbs.toStringAsFixed(0)}g',
                          const Color(0xFF3498DB)),
                      const SizedBox(width: 4),
                      _MiniBadge('F ${food.fat.toStringAsFixed(0)}g',
                          const Color(0xFFE74C3C)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${food.calories.toInt()}',
                  style: const TextStyle(
                      color: Color(0xFFF39C12),
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                ),
                Text('kcal',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.40),
                        fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniBadge(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 9, color: color, fontWeight: FontWeight.w700)),
      );
}

// ── Scan line painter ────────────────────────────────────────────────────────

class _ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;

    // Scan line glow
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 20, size.width, 40));

    canvas.drawRect(Rect.fromLTWH(0, y - 2, size.width, 4), glowPaint);

    // Bright line
    final linePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.0),
          color,
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 2));

    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), linePaint);

    // Corner brackets
    final bracketPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const bracketLen = 30.0;
    const margin = 16.0;

    // Top-left
    canvas.drawLine(Offset(margin, margin), Offset(margin + bracketLen, margin), bracketPaint);
    canvas.drawLine(Offset(margin, margin), Offset(margin, margin + bracketLen), bracketPaint);

    // Top-right
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - bracketLen, margin), bracketPaint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + bracketLen), bracketPaint);

    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + bracketLen, size.height - margin), bracketPaint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - bracketLen), bracketPaint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - bracketLen, size.height - margin), bracketPaint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - bracketLen), bracketPaint);
  }

  @override
  bool shouldRepaint(_ScanLinePainter oldDelegate) => oldDelegate.progress != progress;
}
