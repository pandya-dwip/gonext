import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../modules/settings/presentation/providers/settings_provider.dart';
import 'app_router.dart';

/// The root Widget of the GoNext application.
/// It wraps the MaterialApp with the GoRouter and centralized AppTheme.
class GoNextApp extends ConsumerWidget {
  const GoNextApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Watch accent color to trigger rebuild when color preference updates
    ref.watch(accentColorProvider);

    // Resolve system dark mode flag
    final brightness = MediaQuery.of(context).platformBrightness;
    AppColors.isDark = (themeMode == ThemeMode.dark) ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return MaterialApp.router(
      title: 'GoNext',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
