import 'package:flutter/material.dart';

/// Lulu Design System - Spacing
///
/// 일관된 간격 시스템

class LuluSpacing {
  /// 4px
  static const double xs = 4;

  /// 8px
  static const double sm = 8;

  /// 12px
  static const double md = 12;

  /// 16px
  static const double lg = 16;

  /// 20px
  static const double xl = 20;

  /// 24px
  static const double xxl = 24;

  /// 32px
  static const double xxxl = 32;

  /// 48px
  static const double huge = 48;

  // ========================================
  // EdgeInsets Presets
  // ========================================

  /// 화면 패딩 (20px all)
  static const EdgeInsets screenPadding = EdgeInsets.all(20);

  /// 카드 패딩 (16px all)
  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  /// 버튼 패딩 (32px horizontal, 18px vertical)
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 18,
  );

  /// 작은 버튼 패딩 (24px horizontal, 12px vertical)
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );

  /// 입력 필드 패딩 (20px horizontal, 16px vertical)
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );

  /// 칩 패딩 (16px horizontal, 12px vertical)
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  /// 리스트 아이템 패딩 (16px all)
  static const EdgeInsets listItemPadding = EdgeInsets.all(16);

  /// 섹션 간격 (vertical 24px)
  static const EdgeInsets sectionSpacing = EdgeInsets.symmetric(vertical: 24);
}
