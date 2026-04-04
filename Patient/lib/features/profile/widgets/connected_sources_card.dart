import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

/// Connected Health Sources — shows health data connections:
/// Google Fit, Apple Health, smartwatch, manual vitals, nutrition sync,
/// sleep sync, steps sync. Each with status, last sync, reconnect CTA.
class ConnectedSourcesCard extends StatefulWidget {
  const ConnectedSourcesCard({super.key});

  @override
  State<ConnectedSourcesCard> createState() => _ConnectedSourcesCardState();
}

class _ConnectedSourcesCardState extends State<ConnectedSourcesCard> {
  late List<_Source> _sources;

  @override
  void initState() {
    super.initState();
    _sources = [
      const _Source(
        name: 'Google Fit / Health Connect',
        icon: Icons.favorite_rounded,
        color: Color(0xFF10B981),
        connected: false,
        lastSync: '',
      ),
      const _Source(
        name: 'Apple Health',
        icon: Icons.apple_rounded,
        color: Color(0xFF3B82F6),
        connected: false,
        lastSync: '',
      ),
      const _Source(
        name: 'Smartwatch',
        icon: Icons.watch_rounded,
        color: Color(0xFF8B5CF6),
        connected: false,
        lastSync: '',
      ),
      const _Source(
        name: 'Manual Vitals',
        icon: Icons.edit_note_rounded,
        color: Color(0xFF0EA5E9),
        connected: true,
        lastSync: 'Always available',
      ),
      const _Source(
        name: 'Nutrition Sync',
        icon: Icons.restaurant_rounded,
        color: Color(0xFFF59E0B),
        connected: true,
        lastSync: 'Synced',
      ),
      const _Source(
        name: 'Sleep Tracking',
        icon: Icons.bedtime_rounded,
        color: Color(0xFF6366F1),
        connected: false,
        lastSync: '',
      ),
      const _Source(
        name: 'Steps & Activity',
        icon: Icons.directions_walk_rounded,
        color: Color(0xFF14B8A6),
        connected: false,
        lastSync: '',
      ),
    ];
  }

  void _handleConnect(int index) async {
    final source = _sources[index];

    if (source.name.contains('Fit') || source.name.contains('Health')) {
      final status = await Permission.activityRecognition.request();
      if (status.isGranted) {
        setState(() {
          _sources[index] = source.copyWith(
            connected: true,
            lastSync: 'Just now',
          );
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission required to connect health sources.'),
            ),
          );
        }
      }
    } else {
      setState(() {
        _sources[index] = source.copyWith(
          connected: true,
          lastSync: 'Just now',
        );
      });
    }
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.22),
                    width: 0.6,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cable_rounded,
                      size: 12,
                      color: Color(0xFF0EA5E9),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Health Sources',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF0EA5E9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${_sources.where((s) => s.connected).length}/${_sources.length} active',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.40)
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._sources.asMap().entries.map(
            (entry) => _SourceRow(
              source: entry.value,
              onConnect: () => _handleConnect(entry.key),
            ),
          ),
        ],
      ),
    );
  }
}

class _Source {
  final String name;
  final IconData icon;
  final Color color;
  final bool connected;
  final String lastSync;

  const _Source({
    required this.name,
    required this.icon,
    required this.color,
    required this.connected,
    required this.lastSync,
  });

  _Source copyWith({
    String? name,
    IconData? icon,
    Color? color,
    bool? connected,
    String? lastSync,
  }) {
    return _Source(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      connected: connected ?? this.connected,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}

class _SourceRow extends StatelessWidget {
  final _Source source;
  final VoidCallback onConnect;

  const _SourceRow({required this.source, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: source.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(source.icon, size: 15, color: source.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (source.connected && source.lastSync.isNotEmpty)
                  Text(
                    source.lastSync,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.35)
                          : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (source.connected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onConnect,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  'Connect',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.50)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
