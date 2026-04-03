/// Food Image Recognition Screen — FatSecret AI
/// Pick from camera or gallery → animated scan → results with nutrition
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
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
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 20, color: Color(0xFF58D68D)),
            SizedBox(width: 8),
            Text('Food Scanner', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Image preview area
          Expanded(
            flex: _result != null ? 2 : 3,
            child: _buildImageArea(),
          ),

          // Results area
          if (_result != null) Expanded(flex: 3, child: _buildResults()),

          // Bottom action buttons (when no result)
          if (_result == null && !_isScanning) _buildBottomActions(),
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
      color: const Color(0xFF161B22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF58D68D).withValues(alpha: 0.2),
                  const Color(0xFF3498DB).withValues(alpha: 0.2),
                ],
              ),
              border: Border.all(color: const Color(0xFF58D68D).withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF58D68D), size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'Take a photo of your food',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI will identify foods and calculate nutrition',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
          ),
        ],
      ),
    );
  }

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
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              // Gallery
              Expanded(
                child: _ActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  color: const Color(0xFF3498DB),
                  onTap: () => _pickImage(fromCamera: false),
                ),
              ),
              const SizedBox(width: 16),
              // Camera
              Expanded(
                child: _ActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  color: const Color(0xFF58D68D),
                  onTap: () => _pickImage(fromCamera: true),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Supports JPG, PNG, WebP • Max 1MB',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final result = _result!;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _resultSlideController, curve: Curves.easeOutCubic)),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161B22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle + title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Foods Detected',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${result.foods.length} items • ${result.totalCalories} kcal total',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                          ),
                        ],
                      ),
                      // Re-scan button
                      IconButton(
                        onPressed: () => _pickImage(fromCamera: false),
                        icon: const Icon(Icons.refresh, color: Color(0xFF58D68D)),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF58D68D).withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Macro summary bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF58D68D).withValues(alpha: 0.15),
                    const Color(0xFF3498DB).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF58D68D).withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroChip(label: 'Calories', value: '${result.totalCalories}', unit: 'kcal', color: const Color(0xFFF39C12)),
                  _MacroChip(label: 'Protein', value: result.totalProtein.toStringAsFixed(1), unit: 'g', color: const Color(0xFF58D68D)),
                  _MacroChip(label: 'Carbs', value: result.totalCarbs.toStringAsFixed(1), unit: 'g', color: const Color(0xFF3498DB)),
                  _MacroChip(label: 'Fat', value: result.totalFat.toStringAsFixed(1), unit: 'g', color: const Color(0xFFE74C3C)),
                ],
              ),
            ),

            // Food items list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: result.foods.length,
                itemBuilder: (context, index) {
                  final food = result.foods[index];
                  return _FoodResultCard(
                    food: food,
                    onTap: () {
                      // Navigate to food detail with MealEntity
                      context.push('/nutrition/food-detail', extra: {
                        'meal': food.toMealEntity(),
                        'mealType': widget.initialMealType ?? MealType.snack,
                      });
                    },
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
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF58D68D).withValues(alpha: 0.2),
                const Color(0xFF3498DB).withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant, color: Color(0xFF58D68D), size: 22),
        ),
        title: Text(
          food.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${food.servingDescription} • ${food.totalMetricAmount.toStringAsFixed(0)}${food.metricUnit}',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${food.calories.toInt()} kcal',
              style: const TextStyle(color: Color(0xFFF39C12), fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              'P:${food.protein.toStringAsFixed(0)} C:${food.carbs.toStringAsFixed(0)} F:${food.fat.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
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
