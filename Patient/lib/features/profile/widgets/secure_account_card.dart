import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Secure Account Card — logout, change password, 2FA, trusted devices,
/// active sessions, delete account. Strong trust styling. Pure UI widget.
class SecureAccountCard extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;

  const SecureAccountCard({
    super.key,
    this.onLogout,
    this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      radius: 18,
      blur: 14,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF64748B).withValues(alpha: 0.22),
                      width: 0.6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded,
                        size: 12, color: Color(0xFF64748B)),
                    SizedBox(width: 4),
                    Text('Account & Security',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Account actions
          _AccountAction(
            icon: Icons.lock_reset_rounded,
            label: 'Change Password',
            subtitle: 'Update your login credentials',
            color: const Color(0xFF3B82F6),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset email sent.')),
              );
            },
          ),
          _AccountAction(
            icon: Icons.security_rounded,
            label: 'Two-Factor Authentication',
            subtitle: 'Coming soon — enhanced security',
            color: const Color(0xFF8B5CF6),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text('Soon',
                  style: TextStyle(
                      fontSize: 8,
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w700)),
            ),
          ),
          _AccountAction(
            icon: Icons.devices_rounded,
            label: 'Trusted Devices',
            subtitle: '1 device active',
            color: const Color(0xFF0EA5E9),
          ),
          _AccountAction(
            icon: Icons.history_rounded,
            label: 'Active Sessions',
            subtitle: 'Current session only',
            color: const Color(0xFF10B981),
          ),

          const SizedBox(height: 8),

          // Logout button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onLogout?.call();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.22),
                    width: 0.7),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded,
                      size: 16, color: Color(0xFFEF4444)),
                  SizedBox(width: 6),
                  Text('Secure Logout',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Delete account
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              onDeleteAccount?.call();
            },
            child: Center(
              child: Text('Delete Account',
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _AccountAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimary)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 9,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : AppColors.textSecondary)),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(Icons.chevron_right_rounded,
                  size: 16,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.20)
                      : AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
