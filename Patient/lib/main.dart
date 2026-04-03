import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_notifier.dart';
import 'core/cache/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Initialize Hive local cache
  await CacheService.init();

  runApp(
    // ProviderScope is the root of the Riverpod provider tree
    const ProviderScope(
      child: MedAssistApp(),
    ),
  );
}

class MedAssistApp extends ConsumerWidget {
  const MedAssistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current theme mode from our ThemeNotifier
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'MedAssist AI',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Pass the GoRouter configuration generated in app_router.dart
      routerConfig: AppRouter.router,
    );
  }
}

