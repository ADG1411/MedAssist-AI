import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_background.dart';
import 'providers/auth_provider.dart';
import '../onboarding/providers/onboarding_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailCtrl.text.trim();
      final name = _nameCtrl.text.trim();

      final metadata = {
        'full_name': name,
      };

      final success = await ref.read(authProvider.notifier).signUp(
            email,
            _passCtrl.text,
            metadata,
          );

      if (mounted && success) {
        ref.read(onboardingProvider.notifier).updateBasicInfo(fullName: name);
        context.go('/onboarding-wizard');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Registration failed. Profile may already exist.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppBackground(isDark: isDark),

          SafeArea(
            child: Column(
              children: [
                // Back button row
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.70),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : Colors.white,
                              width: 0.6,
                            ),
                          ),
                          child: Icon(Icons.arrow_back_rounded,
                              size: 16,
                              color:
                                  isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                          24, 8, 24, 20 + bottomInset),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6)
                                        .withValues(alpha: 0.12),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: SvgPicture.asset(
                                  'assets/images/logo.svg',
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'Create Your Account',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Begin your AI-powered health journey',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.45)
                                    : const Color(0xFF64748B),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Glass card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 14, sigmaY: 14),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white
                                            .withValues(alpha: 0.06)
                                        : Colors.white
                                            .withValues(alpha: 0.72),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white
                                              .withValues(alpha: 0.10)
                                          : Colors.white
                                              .withValues(alpha: 0.90),
                                      width: 0.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.06),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Section label
                                      _SectionLabel(
                                          'Account Credentials',
                                          Icons.shield_outlined,
                                          isDark),
                                      const SizedBox(height: 12),

                                      // Email
                                      _GlassFormField(
                                        controller: _emailCtrl,
                                        hint: 'Email Address',
                                        icon: Icons.mail_outline_rounded,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        isDark: isDark,
                                        validator: (val) =>
                                            val != null &&
                                                    val.contains('@')
                                                ? null
                                                : 'Valid email required',
                                      ),
                                      const SizedBox(height: 12),

                                      // Password
                                      _GlassFormField(
                                        controller: _passCtrl,
                                        hint: 'Secure Password',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText: _obscurePassword,
                                        isDark: isDark,
                                        validator: (val) =>
                                            val != null && val.length > 5
                                                ? null
                                                : 'Min 6 characters',
                                        suffix: GestureDetector(
                                          onTap: () => setState(() =>
                                              _obscurePassword =
                                                  !_obscurePassword),
                                          child: Icon(
                                            _obscurePassword
                                                ? Icons
                                                    .visibility_off_outlined
                                                : Icons
                                                    .visibility_outlined,
                                            size: 18,
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.30)
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      _SectionLabel(
                                          'Basic Identity',
                                          Icons.person_outline_rounded,
                                          isDark),
                                      const SizedBox(height: 12),

                                      // Name
                                      _GlassFormField(
                                        controller: _nameCtrl,
                                        hint: 'Full Legal Name',
                                        icon: Icons.badge_outlined,
                                        isDark: isDark,
                                        validator: (val) =>
                                            val != null && val.isNotEmpty
                                                ? null
                                                : 'Name required',
                                      ),

                                      const SizedBox(height: 24),

                                      // Continue button
                                      GestureDetector(
                                        onTap: _isLoading
                                            ? null
                                            : () {
                                                HapticFeedback
                                                    .mediumImpact();
                                                _handleSignup();
                                              },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          height: 52,
                                          decoration: BoxDecoration(
                                            gradient:
                                                const LinearGradient(
                                              colors: [
                                                Color(0xFF3B82F6),
                                                Color(0xFF2563EB),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                        0xFF3B82F6)
                                                    .withValues(
                                                        alpha: 0.30),
                                                blurRadius: 12,
                                                offset:
                                                    const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: _isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .arrow_forward_rounded,
                                                          size: 16,
                                                          color: Colors
                                                              .white),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Continue to Patient Profile',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w700,
                                                          color: Colors
                                                              .white,
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
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Already have account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white
                                            .withValues(alpha: 0.40)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isDark;
  const _SectionLabel(this.text, this.icon, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

// ── Glass Form Field ──────────────────────────────────────────────────────

class _GlassFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool isDark;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _GlassFormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    required this.isDark,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 0.6,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark
                ? Colors.white.withValues(alpha: 0.25)
                : const Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(icon,
              size: 18,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.30)
                  : const Color(0xFF94A3B8)),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          errorStyle: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}

