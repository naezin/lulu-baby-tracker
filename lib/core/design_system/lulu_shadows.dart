import 'package:flutter/material.dart';

/// Lulu Design System - Shadows
///
/// 일관된 그림자 시스템

class LuluShadows {
  // ========================================
  // 카드 그림자 (Card Shadows)
  // ========================================

  /// 기본 카드 그림자
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// 강조된 카드 그림자
  static List<BoxShadow> cardElevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];

  // ========================================
  // Glassmorphism 그림자
  // ========================================

  static List<BoxShadow> glassmorphism = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // ========================================
  // FAB 그림자 (Floating Action Button)
  // ========================================

  static List<BoxShadow> fab({Color? color}) {
    return [
      BoxShadow(
        color: (color ?? const Color(0xFF9D8CD6)).withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];
  }

  // ========================================
  // Bottom Sheet 그림자
  // ========================================

  static List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 24,
      offset: const Offset(0, -4),
    ),
  ];

  // ========================================
  // 작은 그림자 (Subtle)
  // ========================================

  static List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
}
