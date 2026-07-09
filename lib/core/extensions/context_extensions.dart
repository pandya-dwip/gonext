import 'package:flutter/material.dart';

/// BuildContextExtensions provides shorthand extensions on [BuildContext]
/// to easily retrieve styles, themes, and screen dimensions.
extension BuildContextExtensions on BuildContext {
  /// Returns the current [ThemeData]
  ThemeData get theme => Theme.of(this);

  /// Returns the current [ColorScheme] from the theme
  ColorScheme get colors => theme.colorScheme;

  /// Returns the current [TextTheme] from the theme
  TextTheme get textTheme => theme.textTheme;

  /// Returns the current [MediaQueryData]
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the screen width
  double get screenWidth => mediaQuery.size.width;

  /// Returns the screen height
  double get screenHeight => mediaQuery.size.height;

  /// Returns the device padding (safe area offsets)
  EdgeInsets get devicePadding => mediaQuery.padding;

  /// Displays a clean, M3 floating SnackBar for brief messaging
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(
            color: isError ? colors.onError : colors.onPrimary,
          ),
        ),
        backgroundColor: isError ? colors.error : colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
