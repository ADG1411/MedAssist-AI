import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/page_dot_indicator.dart';
import '../../shared/widgets/app_button.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/base_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.psychology,
      'title': 'AI Health Assistant',
      'subtitle': 'Experiencing symptoms? Let our intelligent AI guide you to possible causes and next steps.',
    },
    {
      'icon': Icons.restaurant_menu,
      'title': 'Nutrition Intelligence',
      'subtitle': 'Discover foods that aid your recovery, with personalized dietary insights based on your condition.',
    },
    {
      'icon': Icons.monitor_heart,
      'title': 'Recovery Monitoring',
      'subtitle': 'Track your healing journey day by day with dynamic charts and predictions.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.softBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          page['icon'],
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        page['title'],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page['subtitle'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageDotIndicator(
                  itemCount: _pages.length,
                  currentIndex: _currentIndex,
                ),
                if (_currentIndex == _pages.length - 1)
                  AppButton(
                    text: 'Get Started',
                    onPressed: () => context.go('/login'),
                  )
                else
                  FloatingActionButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

