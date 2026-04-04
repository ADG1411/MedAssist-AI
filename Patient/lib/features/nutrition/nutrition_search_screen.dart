// Nutrition Search Screen — Smart Nutrition Command Center
// Upgraded: AI suggestions, disease-safe foods, Indian presets, glass design
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medassist_ai/core/theme/app_colors.dart';
import 'package:medassist_ai/features/nutrition/models/intake_entry.dart';
import 'package:medassist_ai/features/nutrition/models/meal_entity.dart';
import 'package:medassist_ai/features/nutrition/providers/nutrition_providers.dart';
import '../../../shared/widgets/app_background.dart';

// ── AI quick-search suggestions ───────────────────────────────────────────────
const _aiSuggestions = [
  ('🫀 Safe for heart', 'safe food for heart disease'),
  ('🩸 Low sugar snacks', 'low sugar Indian snacks'),
  ('💪 High protein veg', 'high protein vegetarian dinner'),
  ('🏥 Gastritis safe', 'safe foods for gastritis'),
  ('🧂 Low sodium', 'low sodium Indian meal'),
  ('🌾 High fiber', 'high fiber breakfast India'),
];

const _indianQuickPicks = [
  ('🍲 Dal', 'dal'),
  ('🫓 Roti', 'roti'),
  ('🍚 Rice', 'rice'),
  ('🥛 Milk', 'milk'),
  ('🍌 Banana', 'banana'),
  ('🥚 Egg', 'egg'),
  ('🧀 Paneer', 'paneer'),
  ('🐔 Chicken', 'chicken curry'),
  ('🫘 Rajma', 'rajma'),
  ('🥗 Idli', 'idli'),
];

class NutritionSearchScreen extends ConsumerStatefulWidget {
  final MealType? initialMealType;
  const NutritionSearchScreen({super.key, this.initialMealType});

  @override
  ConsumerState<NutritionSearchScreen> createState() =>
      _NutritionSearchScreenState();
}

class _NutritionSearchScreenState extends ConsumerState<NutritionSearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _indianOnly = false;
  bool _isFocused = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      ref.read(nutritionSearchProvider.notifier).clear();
      return;
    }
    ref
        .read(nutritionSearchProvider.notifier)
        .search(query, indianOnly: _indianOnly);
  }

  void _openFoodDetail(MealEntity meal) {
    HapticFeedback.lightImpact();
    context.push(
      '/nutrition/food-detail',
      extra: {'meal': meal, 'mealType': widget.initialMealType},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final search = ref.watch(nutritionSearchProvider);
    final mealColor = widget.initialMealType?.color ?? AppColors.primary;
    final mealLabel = widget.initialMealType?.label ?? 'Add Food';
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.50)
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          AppBackground(isDark: isDark),
          FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                // ── Glass header ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.28)
                            : Colors.white.withValues(alpha: 0.55),
                        padding: EdgeInsets.fromLTRB(
                          16,
                          MediaQuery.paddingOf(context).top + 10,
                          16,
                          12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.09)
                                          : Colors.white.withValues(
                                              alpha: 0.72,
                                            ),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.12,
                                              )
                                            : Colors.white,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 14,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add to $mealLabel',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: textPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      Text(
                                        'Search food, scan barcode or photo',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textSub,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Meal color dot
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: mealColor.withValues(alpha: 0.18),
                                    border: Border.all(
                                      color: mealColor.withValues(alpha: 0.35),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.initialMealType?.emoji ?? '🍽️',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // ── Search bar ────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.09)
                                          : Colors.white.withValues(
                                              alpha: 0.88,
                                            ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _isFocused
                                            ? mealColor.withValues(alpha: 0.45)
                                            : (isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.12,
                                                    )
                                                  : Colors.black.withValues(
                                                      alpha: 0.07,
                                                    )),
                                        width: _isFocused ? 1.2 : 0.7,
                                      ),
                                      boxShadow: _isFocused
                                          ? [
                                              BoxShadow(
                                                color: mealColor.withValues(
                                                  alpha: 0.15,
                                                ),
                                                blurRadius: 12,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: TextField(
                                      controller: _searchCtrl,
                                      focusNode: _focusNode,
                                      onChanged: (v) {
                                        setState(() {});
                                        if (v.length > 1) _onSearch(v);
                                      },
                                      onSubmitted: _onSearch,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: _indianOnly
                                            ? 'dal, roti, biryani, idli...'
                                            : 'food, brand, safe food for...',
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: textSub,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search_rounded,
                                          size: 20,
                                          color: mealColor,
                                        ),
                                        suffixIcon: _searchCtrl.text.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(
                                                  Icons.clear_rounded,
                                                  size: 16,
                                                  color: textSub,
                                                ),
                                                onPressed: () {
                                                  _searchCtrl.clear();
                                                  ref
                                                      .read(
                                                        nutritionSearchProvider
                                                            .notifier,
                                                      )
                                                      .clear();
                                                  setState(() {});
                                                },
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 13,
                                              horizontal: 4,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Photo scan
                                _ScanButton(
                                  icon: Icons.camera_alt_rounded,
                                  color: const Color(0xFF10B981),
                                  onTap: () => context.push(
                                    '/nutrition/image-scan',
                                    extra: widget.initialMealType,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Barcode
                                _ScanButton(
                                  icon: Icons.qr_code_scanner_rounded,
                                  color: AppColors.primary,
                                  onTap: () => context.push(
                                    '/nutrition/barcode',
                                    extra: widget.initialMealType,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Indian toggle
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _indianOnly = !_indianOnly);
                                    if (_searchCtrl.text.isNotEmpty) {
                                      _onSearch(_searchCtrl.text);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _indianOnly
                                          ? const Color(
                                              0xFFF97316,
                                            ).withValues(alpha: 0.15)
                                          : (isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.07,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.04,
                                                  )),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _indianOnly
                                            ? const Color(
                                                0xFFF97316,
                                              ).withValues(alpha: 0.40)
                                            : Colors.transparent,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '🇮🇳',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Indian Only',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _indianOnly
                                                ? const Color(0xFFF97316)
                                                : textSub,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
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

                // ── Results or discovery ──────────────────────────────────
                SliverToBoxAdapter(
                  child: search.isLoading
                      ? _buildLoading(isDark)
                      : search.query.isNotEmpty
                      ? _buildResults(search, isDark, textPrimary, textSub)
                      : _buildDiscovery(isDark, search, textPrimary, textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    NutritionSearchState search,
    bool isDark,
    Color textPrimary,
    Color textSub,
  ) {
    if (search.results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'No results for "${search.query}"',
                style: TextStyle(fontSize: 14, color: textSub),
              ),
              const SizedBox(height: 8),
              Text(
                'Try: dal, paneer, roti, chicken',
                style: TextStyle(fontSize: 12, color: textSub),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  '${search.results.length} results',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_indianOnly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🇮🇳 Indian DB',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ...search.results.map(
            (m) => _PremiumFoodCard(
              meal: m,
              isDark: isDark,
              onTap: () => _openFoodDetail(m),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscovery(
    bool isDark,
    NutritionSearchState search,
    Color textPrimary,
    Color textSub,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── AI smart suggestions ──────────────────────────────────
          _SectionLabel('🤖 AI Smart Search', textPrimary),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _aiSuggestions
                .map(
                  (s) => GestureDetector(
                    onTap: () {
                      _searchCtrl.text = s.$2;
                      setState(() {});
                      _onSearch(s.$2);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withValues(alpha: 0.12),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                            0xFF6366F1,
                          ).withValues(alpha: 0.25),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        s.$1,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),

          // ── Recent foods ──────────────────────────────────────────
          if (search.recentFoods.isNotEmpty) ...[
            _SectionLabel('🕐 Recently Logged', textPrimary),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: search.recentFoods
                    .take(8)
                    .map(
                      (e) => _RecentFoodChip(
                        entry: e,
                        isDark: isDark,
                        onTap: () => _openFoodDetail(e.meal),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 18),
          ],

          // ── Indian quick picks ────────────────────────────────────
          _SectionLabel('🇮🇳 Indian Staples', textPrimary),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _indianQuickPicks
                .map(
                  (p) => GestureDetector(
                    onTap: () {
                      _searchCtrl.text = p.$2;
                      setState(() => _indianOnly = true);
                      _onSearch(p.$2);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: const Color(
                            0xFFF97316,
                          ).withValues(alpha: 0.22),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        p.$1,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),

          // ── Disease-safe foods ────────────────────────────────────
          _SectionLabel('🏥 Disease-Safe Foods', textPrimary),
          const SizedBox(height: 8),
          ...[
            (
              'Gastritis Safe',
              'safe foods for gastritis',
              const Color(0xFF10B981),
              '🫁',
            ),
            (
              'Diabetic Friendly',
              'low glycemic Indian foods',
              const Color(0xFF0EA5E9),
              '🩸',
            ),
            (
              'Heart Healthy',
              'heart healthy low sodium foods',
              const Color(0xFFEF4444),
              '🫀',
            ),
            (
              'Kidney Safe',
              'low potassium low protein foods',
              const Color(0xFF8B5CF6),
              '🔬',
            ),
          ].map(
            (item) => GestureDetector(
              onTap: () {
                _searchCtrl.text = item.$2;
                setState(() {});
                _onSearch(item.$2);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.$3.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.$3.withValues(alpha: 0.22),
                    width: 0.7,
                  ),
                ),
                child: Row(
                  children: [
                    Text(item.$4, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            item.$2,
                            style: TextStyle(fontSize: 11, color: textSub),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: item.$3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(bool isDark) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: List.generate(
        4,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 72,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ),
  );
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
  );
}

// ── Scan button ───────────────────────────────────────────────────────────────
class _ScanButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ScanButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

// ── Recent food chip ──────────────────────────────────────────────────────────
class _RecentFoodChip extends StatelessWidget {
  final IntakeEntry entry;
  final bool isDark;
  final VoidCallback onTap;
  const _RecentFoodChip({
    required this.entry,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = entry.meal.name ?? 'Food';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'F';
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.7,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: textSub),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Premium food card ─────────────────────────────────────────────────────────
class _PremiumFoodCard extends StatelessWidget {
  final MealEntity meal;
  final bool isDark;
  final VoidCallback onTap;
  const _PremiumFoodCard({
    required this.meal,
    required this.isDark,
    required this.onTap,
  });

  Color get _sourceColor {
    switch (meal.source) {
      case MealSource.indian:
        return const Color(0xFFF97316);
      case MealSource.off:
        return const Color(0xFF10B981);
      case MealSource.fdc:
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _sourceLabel {
    switch (meal.source) {
      case MealSource.indian:
        return '🇮🇳 IFCT';
      case MealSource.off:
        return '🌍 OFF';
      case MealSource.fdc:
        return '🇺🇸 USDA';
      default:
        return '📝 Custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    final kcal = meal.nutriments.energyKcal100?.toInt() ?? 0;
    final protein = meal.nutriments.proteins100?.toStringAsFixed(1) ?? '–';
    final carbs = meal.nutriments.carbohydrates100?.toStringAsFixed(1) ?? '–';
    final fat = meal.nutriments.fat100?.toStringAsFixed(1) ?? '–';
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : AppColors.textSecondary;
    final name = meal.name ?? 'Unknown food';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'F';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.09)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            // Food image / initial
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: meal.thumbnailImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        meal.thumbnailImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _sourceColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _sourceLabel,
                          style: TextStyle(
                            fontSize: 9,
                            color: _sourceColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (meal.brands != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      meal.brands!,
                      style: TextStyle(fontSize: 10, color: textSub),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _MiniChip('$kcal kcal', const Color(0xFFF59E0B)),
                      const SizedBox(width: 5),
                      _MiniChip('P ${protein}g', const Color(0xFF10B981)),
                      const SizedBox(width: 5),
                      _MiniChip('C ${carbs}g', const Color(0xFF0EA5E9)),
                      const SizedBox(width: 5),
                      _MiniChip('F ${fat}g', const Color(0xFFEF4444)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 18, color: textSub),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700),
    ),
  );
}
