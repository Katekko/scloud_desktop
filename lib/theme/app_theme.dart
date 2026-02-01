import 'package:flutter/material.dart';

import 'serverpod_colors.dart';

/// App theme using Serverpod brand colors (light and dark).
abstract final class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: ServerpodColors.primary,
        onPrimary: ServerpodColors.onPrimary,
        surface: ServerpodColors.surfaceLight,
        onSurface: ServerpodColors.onSurfaceLight,
        error: ServerpodColors.error,
        onError: ServerpodColors.onError,
        secondary: ServerpodColors.accent,
      ),
      scaffoldBackgroundColor: ServerpodColors.surfaceLight,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: ServerpodColors.primaryLight,
        onPrimary: ServerpodColors.onPrimary,
        surface: ServerpodColors.surfaceDark,
        onSurface: ServerpodColors.onSurfaceDark,
        error: ServerpodColors.error,
        onError: ServerpodColors.onError,
        secondary: ServerpodColors.accent,
      ),
      scaffoldBackgroundColor: ServerpodColors.surfaceDark,
    );
  }
}
