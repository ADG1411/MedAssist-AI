import 'dart:math' as math;
import 'package:flutter/material.dart';

class GradientSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function()? onMicPressed;
  final Function()? onSearchPressed;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double height;
  final EdgeInsets padding;

  const GradientSearchBar({
    super.key,
    this.hintText = 'Ask anything...',
    this.onChanged,
    this.onMicPressed,
    this.onSearchPressed,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.height = 56.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
  });

  @override
  State<GradientSearchBar> createState() => _GradientSearchBarState();
}

class _GradientSearchBarState extends State<GradientSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _backgroundAnimation;

  TextEditingController? _internalController;
  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _effectiveController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Trigger rebuild so send button state updates
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant GradientSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      _effectiveController.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _effectiveController.removeListener(_onTextChanged);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Padding(
        padding: widget.padding,
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.0),
                gradient: SweepGradient(
                  center: Alignment.center,
                  startAngle: _rotationAnimation.value * 2 * math.pi,
                  endAngle: (_rotationAnimation.value + 1) * 2 * math.pi,
                  colors: const [
                    Color(0xFFFF6B35),
                    Color(0xFFFF8E53),
                    Color(0xFFFFB366),
                    Color(0xFFFFA726),
                    Color(0xFF42A5F5),
                    Color(0xFF1E88E5),
                    Color(0xFF1976D2),
                    Color(0xFF0D47A1),
                    Color(0xFF7B1FA2),
                    Color(0xFF8E24AA),
                    Color(0xFFAB47BC),
                    Color(0xFFBA68C8),
                    Color(0xFFE1BEE7),
                    Color(0xFFFF6B35),
                  ],
                  stops: const [
                    0.0, 0.08, 0.16, 0.24, 0.32, 0.40, 0.48, 0.56,
                    0.64, 0.72, 0.80, 0.88, 0.96, 1.0,
                  ],
                  tileMode: TileMode.repeated,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(0xFF0A0A0F),
                    const Color(0xFF1A0F1A),
                    (_backgroundAnimation.value * 0.5 + 0.5) *
                        (1 +
                            0.3 *
                                math.sin(_backgroundAnimation.value *
                                    2 *
                                    math.pi)),
                  ),
                  borderRadius: BorderRadius.circular(26.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(
                        const Color(0xFF330066),
                        const Color(0xFF003366),
                        _backgroundAnimation.value,
                      )!
                          .withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Icon(
                        Icons.search,
                        color: _effectiveFocusNode.hasFocus
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _effectiveController,
                        focusNode: _effectiveFocusNode,
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                        textInputAction: TextInputAction.send,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 9.0,
                          ),
                        ),
                      ),
                    ),
                    if (widget.onMicPressed != null)
                      GestureDetector(
                        onTap: widget.onMicPressed,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.mic_outlined,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        if (_effectiveController.text.isNotEmpty) {
                          widget.onSearchPressed?.call();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10.0, left: 4.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: _effectiveController.text.isNotEmpty
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: _effectiveController.text.isNotEmpty
                              ? Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: _effectiveController.text.isNotEmpty
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
