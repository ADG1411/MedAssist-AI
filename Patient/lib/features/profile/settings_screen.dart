// Settings Screen — iOS-native Cupertino style, wired to real app state.
// Notification toggles, theme, account actions, and navigation to existing
// profile routes (/onboarding-wizard, /medassist-card, /sos, /login).
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, Brightness;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/providers/auth_provider.dart';

// ── Local Settings State ───────────────────────────────────────────────────────

final _settingsProvider =
    NotifierProvider<_SettingsNotifier, _SettingsState>(
  _SettingsNotifier.new,
);

class _SettingsState {
  final bool notifications;
  final bool criticalAlerts;
  final bool sosAlerts;
  final bool weeklyReport;
  final bool biometric;
  final bool dataSharing;
  final bool analyticsOptIn;

  const _SettingsState({
    this.notifications = true,
    this.criticalAlerts = true,
    this.sosAlerts = true,
    this.weeklyReport = true,
    this.biometric = false,
    this.dataSharing = false,
    this.analyticsOptIn = true,
  });

  _SettingsState copyWith({
    bool? notifications,
    bool? criticalAlerts,
    bool? sosAlerts,
    bool? weeklyReport,
    bool? biometric,
    bool? dataSharing,
    bool? analyticsOptIn,
  }) =>
      _SettingsState(
        notifications: notifications ?? this.notifications,
        criticalAlerts: criticalAlerts ?? this.criticalAlerts,
        sosAlerts: sosAlerts ?? this.sosAlerts,
        weeklyReport: weeklyReport ?? this.weeklyReport,
        biometric: biometric ?? this.biometric,
        dataSharing: dataSharing ?? this.dataSharing,
        analyticsOptIn: analyticsOptIn ?? this.analyticsOptIn,
      );
}

class _SettingsNotifier extends Notifier<_SettingsState> {
  @override
  _SettingsState build() => const _SettingsState();

  void toggle(String key) {
    switch (key) {
      case 'notifications':
        state = state.copyWith(notifications: !state.notifications);
      case 'criticalAlerts':
        state = state.copyWith(criticalAlerts: !state.criticalAlerts);
      case 'sosAlerts':
        state = state.copyWith(sosAlerts: !state.sosAlerts);
      case 'weeklyReport':
        state = state.copyWith(weeklyReport: !state.weeklyReport);
      case 'biometric':
        state = state.copyWith(biometric: !state.biometric);
      case 'dataSharing':
        state = state.copyWith(dataSharing: !state.dataSharing);
      case 'analyticsOptIn':
        state = state.copyWith(analyticsOptIn: !state.analyticsOptIn);
    }
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!mounted) return;
      setState(() => _isSearchActive = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Honour the app's Material theme brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(_settingsProvider);

    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final cardColor =
        isDark ? const Color(0xFF2C2C2E) : CupertinoColors.secondarySystemGroupedBackground;
    final dividerColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
    final labelColor = isDark ? CupertinoColors.white : CupertinoColors.label;
    final subColor = isDark ? const Color(0xFF8E8E93) : CupertinoColors.secondaryLabel;

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: bgColor.withOpacity(isDark ? 0.85 : 0.90),
        border: null,
        middle: Text(
          'Settings',
          style: TextStyle(color: labelColor, fontWeight: FontWeight.w600),
        ),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(
            CupertinoIcons.chevron_left,
            size: 20,
            color: CupertinoColors.activeBlue,
          ),
        ),
      ),
      child: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, _isSearchActive ? 8 : 12, 16, 32),
            children: [
              // ── Search ────────────────────────────────────────────────
              _animatedSearchBar(isDark, labelColor),
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                height: _isSearchActive ? 10 : 14,
              ),

              // ── Account section ───────────────────────────────────────
              _sectionHeader('Account', subColor),
              _section(cardColor, dividerColor, [
                _navCell(
                  'Medical Profile',
                  CupertinoIcons.person_fill,
                  CupertinoColors.activeBlue,
                  labelColor,
                  subColor,
                  onTap: () => context.push('/onboarding-wizard'),
                ),
                _navCell(
                  'Digital Health ID',
                  CupertinoIcons.qrcode,
                  CupertinoColors.systemPurple,
                  labelColor,
                  subColor,
                  onTap: () => context.push('/medassist-card'),
                ),
                _navCell(
                  'Emergency SOS',
                  CupertinoIcons.exclamationmark_shield_fill,
                  CupertinoColors.systemRed,
                  labelColor,
                  subColor,
                  trailingText: 'Configure',
                  onTap: () => context.push('/sos'),
                ),
              ]),

              const SizedBox(height: 14),

              // ── Notifications ──────────────────────────────────────────
              _sectionHeader('Notifications', subColor),
              _section(cardColor, dividerColor, [
                _toggleCell(
                  'Push Notifications',
                  CupertinoIcons.bell_fill,
                  CupertinoColors.systemRed,
                  labelColor,
                  settings.notifications,
                  () => ref.read(_settingsProvider.notifier).toggle('notifications'),
                ),
                _toggleCell(
                  'Critical Health Alerts',
                  CupertinoIcons.heart_fill,
                  CupertinoColors.systemPink,
                  labelColor,
                  settings.criticalAlerts,
                  () => ref.read(_settingsProvider.notifier).toggle('criticalAlerts'),
                ),
                _toggleCell(
                  'SOS & Emergency',
                  CupertinoIcons.shield_fill,
                  CupertinoColors.systemOrange,
                  labelColor,
                  settings.sosAlerts,
                  () => ref.read(_settingsProvider.notifier).toggle('sosAlerts'),
                ),
                _toggleCell(
                  'Weekly Recovery Report',
                  CupertinoIcons.chart_bar_alt_fill,
                  CupertinoColors.systemGreen,
                  labelColor,
                  settings.weeklyReport,
                  () => ref.read(_settingsProvider.notifier).toggle('weeklyReport'),
                ),
              ]),

              const SizedBox(height: 14),

              // ── Privacy & Security ─────────────────────────────────────
              _sectionHeader('Privacy & Security', subColor),
              _section(cardColor, dividerColor, [
                _toggleCell(
                  'Face ID / Biometric',
                  CupertinoIcons.lock_shield_fill,
                  CupertinoColors.systemGreen,
                  labelColor,
                  settings.biometric,
                  () => ref.read(_settingsProvider.notifier).toggle('biometric'),
                ),
                _toggleCell(
                  'Share Data with Doctors',
                  CupertinoIcons.person_2_fill,
                  CupertinoColors.activeBlue,
                  labelColor,
                  settings.dataSharing,
                  () => ref.read(_settingsProvider.notifier).toggle('dataSharing'),
                ),
                _toggleCell(
                  'Analytics & Improvement',
                  CupertinoIcons.graph_square_fill,
                  CupertinoColors.systemIndigo,
                  labelColor,
                  settings.analyticsOptIn,
                  () => ref.read(_settingsProvider.notifier).toggle('analyticsOptIn'),
                ),
                _navCell(
                  'Privacy Policy',
                  CupertinoIcons.hand_raised_fill,
                  CupertinoColors.activeBlue,
                  labelColor,
                  subColor,
                ),
              ]),

              const SizedBox(height: 14),

              // ── MedAssist Features ─────────────────────────────────────
              _sectionHeader('MedAssist Features', subColor),
              _section(cardColor, dividerColor, [
                _navCell(
                  'AI Check-in',
                  CupertinoIcons.waveform_path_ecg,
                  CupertinoColors.systemPurple,
                  labelColor,
                  subColor,
                  trailingText: 'Daily',
                  onTap: () => context.push('/monitoring'),
                ),
                _navCell(
                  'Recovery Report',
                  CupertinoIcons.chart_bar_fill,
                  CupertinoColors.systemGreen,
                  labelColor,
                  subColor,
                  onTap: () => context.push('/recovery-report'),
                ),
                _navCell(
                  'Health Records',
                  CupertinoIcons.folder_fill,
                  CupertinoColors.systemOrange,
                  labelColor,
                  subColor,
                  onTap: () => context.push('/records'),
                ),
                _navCell(
                  'Connected Doctors',
                  CupertinoIcons.heart_circle_fill,
                  CupertinoColors.systemRed,
                  labelColor,
                  subColor,
                  onTap: () => context.push('/doctors'),
                ),
              ]),

              const SizedBox(height: 14),

              // ── About ──────────────────────────────────────────────────
              _sectionHeader('About', subColor),
              _section(cardColor, dividerColor, [
                _navCell(
                  'App Version',
                  CupertinoIcons.info_circle_fill,
                  CupertinoColors.systemGrey,
                  labelColor,
                  subColor,
                  trailingText: '2.0.0',
                ),
                _navCell(
                  'Terms of Service',
                  CupertinoIcons.doc_text_fill,
                  CupertinoColors.systemGrey,
                  labelColor,
                  subColor,
                ),
                _navCell(
                  'Open Source Licenses',
                  CupertinoIcons.doc_fill,
                  CupertinoColors.systemGrey,
                  labelColor,
                  subColor,
                ),
              ]),

              const SizedBox(height: 24),

              // ── Logout ─────────────────────────────────────────────────
              _section(cardColor, dividerColor, [
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  onPressed: () => _confirmLogout(context, ref),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(CupertinoIcons.square_arrow_left,
                          color: CupertinoColors.systemRed, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 10),
              Center(
                child: Text(
                  'MedAssist AI  ·  v2.0.0  ·  Built with ❤️',
                  style: TextStyle(
                    fontSize: 11,
                    color: subColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Animated Search ──────────────────────────────────────────────────────

  Widget _animatedSearchBar(bool isDark, Color labelColor) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, _isSearchActive ? -1.0 : 0.0),
            child: CupertinoSearchTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              placeholder: 'Search Settings',
              style: TextStyle(color: labelColor),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              onTap: () {
                if (!_isSearchActive) setState(() => _isSearchActive = true);
              },
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: _isSearchActive
                ? Row(children: [
                    const SizedBox(width: 8),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _isSearchActive ? 1 : 0,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 30,
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                          setState(() => _isSearchActive = false);
                        },
                        child: const Text('Cancel',
                            style: TextStyle(fontSize: 17)),
                      ),
                    ),
                  ])
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  // ── Building Blocks ────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _section(
      Color cardColor, Color dividerColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Container(height: 0.5, color: dividerColor),
            );
          }
          return children[i ~/ 2];
        }),
      ),
    );
  }

  Widget _navCell(
    String title,
    IconData icon,
    Color iconColor,
    Color labelColor,
    Color subColor, {
    String trailingText = '',
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      onPressed: onTap ?? () {},
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      child: Row(
        children: [
          _leadingIcon(icon, iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: labelColor,
                  fontWeight: FontWeight.w400),
            ),
          ),
          if (trailingText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(trailingText,
                  style: TextStyle(fontSize: 14, color: subColor)),
            ),
          Icon(CupertinoIcons.chevron_right,
              size: 15, color: subColor.withOpacity(0.7)),
        ],
      ),
    );
  }

  Widget _toggleCell(
    String title,
    IconData icon,
    Color iconColor,
    Color labelColor,
    bool value,
    VoidCallback onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
      child: Row(
        children: [
          _leadingIcon(icon, iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: labelColor,
                  fontWeight: FontWeight.w400),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: CupertinoColors.activeBlue,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }

  Widget _leadingIcon(IconData icon, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 16, color: CupertinoColors.white),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
            'This will securely clear your local medical session.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
