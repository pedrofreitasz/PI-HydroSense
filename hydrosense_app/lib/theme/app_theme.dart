import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A5DC7);
  static const Color primaryLight = Color(0xFF3B7DE8);
  static const Color primarySurface = Color(0xFFEEF3FD);
  static const Color greenAccent = Color(0xFF2E8B57);
  static const Color greenSurface = Color(0xFFEAF7F0);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color cardBg = Colors.white;
  static const Color scaffoldBg = Color(0xFFF5F7FB);
  static const Color divider = Color(0xFFE5E9F2);

  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ],
  );
}