import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'app_router.dart';

/// The root Widget of the GoNext application.
/// It wraps the MaterialApp with the GoRouter and centralized AppTheme.
class GoNextApp extends ConsumerWidget {
  const GoNextApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GoNext',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
