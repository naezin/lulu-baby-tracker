import 'package:flutter/material.dart';

/// Lulu Design System - Colors
///
/// Midnight Blue 다크 테마 기반 컬러 시스템
/// 🌙 밤의 평화로운 수면을 표현하는 색상 팔레트

class LuluColors {
  // ========================================
  // Background Gradient (Midnight Blue Palette)
  // ========================================

  /// 가장 어두운 배경 (Scaffold)
  static const Color midnightNavy = Color(0xFF0D1B2A);

  /// 카드 배경
  static const Color deepBlue = Color(0xFF1B263B);

  /// Secondary 요소
  static const Color softBlue = Color(0xFF415A77);

  // ========================================
  // Brand Accent Colors
  // ========================================

  /// Primary Accent ⭐ (라벤더 미스트)
  static const Color lavenderMist = Color(0xFF9D8CD6);

  /// Lighter Accent
  static const Color lavenderGlow = Color(0xFFB4A5E6);

  /// 🦉 Logo Color (달빛 - Champagne Gold)
  static const Color champagneGold = Color(0xFFD4AF6A);

  // ========================================
  // Surface Colors
  // ========================================

  /// Scaffold 배경
  static const Color surfaceDark = Color(0xFF0D1B2A);

  /// Card 배경
  static const Color surfaceCard = Color(0xFF1B263B);

  /// Elevated 요소 (TextField, Chip 등)
  static const Color surfaceElevated = Color(0xFF2A3F5F);

  // ========================================
  // Logo Colors
  // ========================================

  /// 로고 배경 (Deep Midnight)
  static const Color logoBackground = Color(0xFF0D1321);

  /// 로고 전경 (Champagne Gold)
  static const Color logoForeground = Color(0xFFD4AF6A);

  // ========================================
  // Glassmorphism
  // ========================================

  /// Glassmorphism Border
  static const Color glassBorder = Color(0x1AFFFFFF);

  /// Glassmorphism Background
  static Color glassBackground = Colors.white.withOpacity(0.08);
}

/// Text Colors (텍스트 컬러)
class LuluTextColors {
  /// 100% - 제목, 중요 텍스트
  static const Color primary = Color(0xFFE9ECEF);

  /// 70% - 본문, 설명
  static const Color secondary = Color(0xFFADB5BD);

  /// 50% - 힌트, 비활성
  static const Color tertiary = Color(0xFF6C757D);

  /// 30% - 비활성 요소
  static const Color disabled = Color(0xFF495057);
}

/// Activity Colors (활동별 컬러)
class LuluActivityColors {
  /// 수면 - Soft Purple
  static const Color sleep = Color(0xFF9575CD);

  /// 수유 - Soft Orange
  static const Color feeding = Color(0xFFFFB74D);

  /// 기저귀 - Soft Blue
  static const Color diaper = Color(0xFF4FC3F7);

  /// 놀이 - Soft Green
  static const Color play = Color(0xFF81C784);

  /// 건강 - Soft Red
  static const Color health = Color(0xFFE57373);

  // ========================================
  // Background Colors (10% opacity)
  // ========================================

  static Color get sleepBg => sleep.withOpacity(0.1);
  static Color get feedingBg => feeding.withOpacity(0.1);
  static Color get diaperBg => diaper.withOpacity(0.1);
  static Color get playBg => play.withOpacity(0.1);
  static Color get healthBg => health.withOpacity(0.1);

  /// 활동 타입으로 색상 가져오기
  static Color forType(String type) {
    switch (type.toLowerCase()) {
      case 'sleep':
        return sleep;
      case 'feeding':
        return feeding;
      case 'diaper':
        return diaper;
      case 'play':
        return play;
      case 'health':
      case 'temperature':
      case 'medication':
        return health;
      default:
        return LuluColors.lavenderMist;
    }
  }

  /// 활동 타입으로 배경 색상 가져오기
  static Color forTypeBg(String type) {
    return forType(type).withOpacity(0.1);
  }
}

/// Status Colors (상태 컬러)
class LuluStatusColors {
  /// 성공, 완료
  static const Color success = Color(0xFF5FB37B);

  /// 경고, 주의
  static const Color warning = Color(0xFFE8B87E);

  /// 오류, 긴급
  static const Color error = Color(0xFFE87878);

  /// 정보
  static const Color info = Color(0xFF7BB8E8);

  // ========================================
  // Sweet Spot Gauge
  // ========================================

  /// 최적 시간 (Green)
  static const Color optimal = Color(0xFF5FB37B);

  /// 접근 중 (Yellow)
  static const Color approaching = Color(0xFFE8B87E);

  /// 과로 상태 (Red)
  static const Color overtired = Color(0xFFE87878);

  // ========================================
  // Emergency Mode
  // ========================================

  static const Color emergencyRed = Color(0xFFFF6B6B);
  static const Color emergencyBg = Color(0xFF2D1F1F);

  // ========================================
  // Soft Background for Status
  // ========================================

  static Color get successSoft => success.withOpacity(0.15);
  static Color get warningSoft => warning.withOpacity(0.15);
  static Color get errorSoft => error.withOpacity(0.15);
  static Color get infoSoft => info.withOpacity(0.15);
}
