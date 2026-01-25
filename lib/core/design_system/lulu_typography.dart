import 'package:flutter/material.dart';
import 'lulu_colors.dart';

/// Lulu Design System - Typography
///
/// iOS 네이티브 느낌의 산세리프 타이포그래피 시스템

class LuluFonts {
  /// Primary: iOS 네이티브 느낌의 산세리프
  static const String display = 'SF Pro Display';
  static const String text = 'SF Pro Text';
  static const String rounded = 'SF Rounded';

  /// Fallback for Android/Web
  static const List<String> fallback = [
    'Roboto',
    'Noto Sans KR', // 한국어 지원
    'sans-serif',
  ];
}

/// Text Styles
class LuluTextStyles {
  // ========================================
  // Display - 큰 제목
  // ========================================

  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    fontFamily: 'SF Pro Display',
    letterSpacing: -0.8,
    height: 1.2,
    color: LuluTextColors.primary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: 'SF Pro Display',
    letterSpacing: -0.6,
    height: 1.25,
    color: LuluTextColors.primary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'SF Pro Display',
    letterSpacing: -0.4,
    height: 1.3,
    color: LuluTextColors.primary,
  );

  // ========================================
  // Title - 섹션 제목
  // ========================================

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    fontFamily: 'SF Pro Text',
    letterSpacing: -0.3,
    color: LuluTextColors.primary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontFamily: 'SF Pro Text',
    letterSpacing: -0.3,
    color: LuluTextColors.primary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontFamily: 'SF Pro Text',
    letterSpacing: -0.2,
    color: LuluTextColors.primary,
  );

  // ========================================
  // Body - 본문
  // ========================================

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontFamily: 'SF Pro Text',
    letterSpacing: -0.4,
    height: 1.5,
    color: LuluTextColors.primary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontFamily: 'SF Pro Text',
    letterSpacing: -0.2,
    height: 1.4,
    color: LuluTextColors.secondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontFamily: 'SF Pro Text',
    letterSpacing: -0.1,
    color: LuluTextColors.tertiary,
  );

  // ========================================
  // Label - 버튼, 탭
  // ========================================

  static const TextStyle labelLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontFamily: 'SF Pro Text',
    letterSpacing: -0.4,
    color: LuluTextColors.primary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontFamily: 'SF Pro Text',
    letterSpacing: -0.2,
    color: LuluTextColors.primary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: 'SF Pro Text',
    letterSpacing: -0.1,
    color: LuluTextColors.secondary,
  );

  // ========================================
  // Counter - 수치 (Rounded 폰트)
  // ========================================

  static const TextStyle counter = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    fontFamily: 'SF Rounded',
    letterSpacing: -1.0,
    color: LuluTextColors.primary,
  );

  static const TextStyle counterSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'SF Rounded',
    letterSpacing: -0.5,
    color: LuluTextColors.primary,
  );

  // ========================================
  // Caption - 작은 설명 텍스트
  // ========================================

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontFamily: 'SF Pro Text',
    letterSpacing: 0,
    color: LuluTextColors.tertiary,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'SF Pro Text',
    letterSpacing: 0,
    color: LuluTextColors.secondary,
  );
}
