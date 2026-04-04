import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/onboarding_wizard_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../shared/navigation/scaffold_with_bottom_nav.dart';
import '../../features/dashboard/home_screen.dart';
import '../../features/body_map/body_map_screen.dart';
import '../../features/symptom_chat/symptom_chat_screen.dart';
import '../../features/ai_result/ai_result_screen.dart';
import '../../features/deep_check/deep_check_screen.dart';

import '../../features/doctors/doctor_explorer_screen.dart';
import '../../features/doctors/doctor_detail_screen.dart';
import '../../features/consultation/consultation_screen.dart';
import '../../features/consultation/post_consult_screen.dart';
import '../../features/hospitals/hospital_screen.dart';
import '../../features/nutrition/nutrition_diary_screen.dart';
import '../../features/nutrition/nutrition_search_screen.dart';
import '../../features/nutrition/food_detail_screen.dart';
import '../../features/nutrition/barcode_scanner_screen.dart';
import '../../features/nutrition/nutrition_history_screen.dart';
import '../../features/nutrition/nutrition_ai_screen.dart';
import '../../features/nutrition/activity_search_screen.dart';
import '../../features/nutrition/food_image_recognition_screen.dart';
import '../../features/monitoring/monitoring_screen.dart';
import '../../features/monitoring/recovery_report_screen.dart';
import '../../features/monitoring/daily_followup_screen.dart';
import '../../features/records/health_records_screen.dart';
import '../../features/records/medassist_card_screen.dart';
import '../../features/pharmacy/pharmacy_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/sos/sos_screen.dart';
import '../../features/health/health_connect_screen.dart';
import '../../features/health/health_detail_screen.dart';

class AppRouter {
  AppRouter._();

  static CustomTransitionPage _slideRTL(Widget child, LocalKey? key) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        final fade = Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));
        return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
      },
    );
  }

  static CustomTransitionPage _slideBTT(Widget child, LocalKey? key) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        final fade = Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.45, curve: Curves.easeOut)));
        return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
      },
    );
  }

  static CustomTransitionPage _fade(Widget child, LocalKey? key) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.96, end: 1.0)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fade(const SplashScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fade(const OnboardingScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/onboarding-wizard',
        pageBuilder: (context, state) => _slideRTL(const OnboardingWizardScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _slideRTL(const LoginScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => _slideRTL(const SignupScreen(), state.pageKey),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/doctors',
            pageBuilder: (context, state) => const NoTransitionPage(child: DoctorExplorerScreen()),
          ),
          GoRoute(
            path: '/nutrition',
            pageBuilder: (context, state) => const NoTransitionPage(child: NutritionDiaryScreen()),
          ),
          GoRoute(
            path: '/records',
            pageBuilder: (context, state) => const NoTransitionPage(child: HealthRecordsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/nutrition/search',
        pageBuilder: (context, state) => _slideBTT(NutritionSearchScreen(initialMealType: state.extra as dynamic), state.pageKey),
      ),
      GoRoute(
        path: '/nutrition/barcode',
        pageBuilder: (context, state) => _slideRTL(BarcodeScannerScreen(initialMealType: state.extra as dynamic), state.pageKey),
      ),
      GoRoute(
        path: '/nutrition/history',
        pageBuilder: (context, state) => _slideRTL(const NutritionHistoryScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/nutrition/ai',
        pageBuilder: (context, state) => _slideRTL(const NutritionAiScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/nutrition/activity-search',
        pageBuilder: (context, state) => _slideBTT(const ActivitySearchScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/nutrition/image-scan',
        pageBuilder: (context, state) => _slideBTT(
          FoodImageRecognitionScreen(initialMealType: state.extra as dynamic),
          state.pageKey,
        ),
      ),
      GoRoute(
        path: '/nutrition/food-detail',
        pageBuilder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return _slideBTT(FoodDetailScreen(meal: extras['meal'], initialMealType: extras['mealType']), state.pageKey);
        },
      ),
      GoRoute(
        path: '/symptom-check',
        pageBuilder: (context, state) => _slideBTT(const BodyMapScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/symptom-chat',
        pageBuilder: (context, state) => _slideRTL(const SymptomChatScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/ai-result',
        pageBuilder: (context, state) => _slideRTL(const AiResultScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/deep-check',
        pageBuilder: (context, state) => _slideRTL(const DeepCheckScreen(), state.pageKey), // Wait, wait screen mock
      ),
      GoRoute(
        path: '/doctor-detail',
        pageBuilder: (context, state) {
          final doctor = state.extra as Map<String, dynamic>;
          return _slideRTL(DoctorDetailScreen(doctor: doctor), ValueKey('/doctor-detail/${doctor['id']}'));
        },
      ),
      GoRoute(
        path: '/consultation',
        pageBuilder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return _slideBTT(
            ConsultationScreen(
              bookingId: extras['bookingId'] as String? ?? 'democall_000',
              doctorName: extras['doctorName'] as String? ?? 'Doctor',
              jitsiRoom: extras['jitsiRoom'] as String? ?? 'medassist_default',
            ),
            state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/post-consult',
        pageBuilder: (context, state) {
          final bookingId = state.extra as String? ?? 'democall_000';
          return _fade(PostConsultScreen(bookingId: bookingId), state.pageKey);
        },
      ),

      GoRoute(
        path: '/hospitals',
        pageBuilder: (context, state) => _slideRTL(const HospitalScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/monitoring',
        pageBuilder: (context, state) => _slideRTL(const MonitoringScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/recovery-report',
        pageBuilder: (context, state) => _slideRTL(const RecoveryReportScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/daily-followup',
        pageBuilder: (context, state) => _slideBTT(const DailyFollowupScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/medassist-card',
        pageBuilder: (context, state) => _slideBTT(const MedAssistCardScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/pharmacy',
        pageBuilder: (context, state) => _slideRTL(const PharmacyScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/sos',
        pageBuilder: (context, state) => _slideBTT(const SosScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/health-connect',
        pageBuilder: (context, state) => _slideRTL(const HealthConnectScreen(), state.pageKey),
      ),
      GoRoute(
        path: '/health-detail',
        pageBuilder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return _slideRTL(
            HealthDetailScreen(
              metricName: extras['metricName'] as String,
              unit: extras['unit'] as String,
              icon: extras['icon'] as IconData,
              color: extras['color'] as Color,
              currentValue: extras['currentValue'] as String,
            ),
            state.pageKey,
          );
        },
      ),
    ],
  );
}

