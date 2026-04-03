import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feature_flag_service.dart';

/// Widget wrapper that conditionally renders based on a feature flag.
///
/// Usage:
/// ```dart
/// FeatureFlagGuard(
///   flag: FeatureFlags.doctorConsult,
///   child: BookDoctorButton(),
///   fallback: ComingSoonBadge(),
/// )
/// ```
class FeatureFlagGuard extends ConsumerWidget {
  final String flag;
  final Widget child;
  final Widget? fallback;

  const FeatureFlagGuard({
    super.key,
    required this.flag,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagProvider);
    final isEnabled = flags[flag] ?? false;

    if (isEnabled) return child;
    return fallback ?? const SizedBox.shrink();
  }
}
