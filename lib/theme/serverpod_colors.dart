import 'package:flutter/material.dart';

/// Serverpod brand color constants (from serverpod.dev / Serverpod Cloud).
/// Primary and surface colors for light and dark themes.
abstract final class ServerpodColors {
  ServerpodColors._();

  // Primary (blue aligned with Serverpod branding)
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF6366F1);

  // Surface / background
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceDarkSecondary = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceLightSecondary = Color(0xFFF1F5F9);

  // On-primary / on-surface
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFF1F5F9);
  static const Color onSurfaceLight = Color(0xFF0F172A);

  // Error
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);

  // Secondary / accent
  static const Color accent = Color(0xFF818CF8);
}
