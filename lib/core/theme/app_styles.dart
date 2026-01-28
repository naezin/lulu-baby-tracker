import 'package:flutter/material.dart';
import 'app_theme.dart';

/// 🎨 앱 전체 공통 스타일
/// 중복 코드 제거 및 UI 일관성 확보
class AppStyles {
  // ==================== Container Styles ====================

  /// Glassmorphism 카드 데코레이션
  static BoxDecoration glassCard({
    Color? color,
    double borderRadius = 20,
    double borderOpacity = 0.3,
  }) {
    return BoxDecoration(
      color: color ?? const Color(0x1AFFFFFF),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
      ),
    );
  }

  /// Settings 카드 데코레이션
  static BoxDecoration settingsCard({
    Color? backgroundColor,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? const Color(0x1AFFFFFF),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: const Color(0x33FFFFFF)),
    );
  }

  /// 정보 카드 (Info/Warning/Success)
  static BoxDecoration infoCard({
    required Color accentColor,
    double borderRadius = 12,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: accentColor.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: accentColor.withOpacity(0.3),
      ),
    );
  }

  /// Danger Zone 카드
  static BoxDecoration dangerCard({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: Colors.red.withOpacity(0.05),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.red.withOpacity(0.3),
        width: 2,
      ),
    );
  }

  /// 입력 필드 데코레이션
  static BoxDecoration inputField({
    Color? backgroundColor,
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? const Color(0xFF1A2332),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    );
  }

  // ==================== Text Styles ====================

  /// 섹션 헤더 텍스트
  static TextStyle sectionHeader({
    Color? color,
    double fontSize = 14,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color ?? AppTheme.lavenderMist,
    );
  }

  /// 본문 텍스트
  static TextStyle bodyText({
    Color? color,
    double fontSize = 14,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color ?? AppTheme.textPrimary,
      height: height,
    );
  }

  /// 보조 텍스트
  static TextStyle caption({
    Color? color,
    double fontSize = 12,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color ?? AppTheme.textSecondary,
      height: height,
    );
  }

  /// 제목 텍스트
  static TextStyle title({
    Color? color,
    double fontSize = 18,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color ?? Colors.white,
    );
  }

  /// 대형 제목 텍스트
  static TextStyle headline({
    Color? color,
    double fontSize = 24,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color ?? Colors.white,
    );
  }

  /// 라벨 텍스트 (input labels 등)
  static TextStyle label({
    Color? color,
    double fontSize = 14,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.white70,
    );
  }

  // ==================== Button Styles ====================

  /// 기본 버튼 스타일
  static ButtonStyle primaryButton({
    Color? backgroundColor,
    Color? foregroundColor,
    double borderRadius = 16,
    double minHeight = 56,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppTheme.lavenderMist,
      foregroundColor: foregroundColor ?? Colors.white,
      minimumSize: Size(double.infinity, minHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 0,
    );
  }

  /// Danger 버튼 스타일 (삭제 등)
  static ButtonStyle dangerButton({
    double borderRadius = 12,
    double minHeight = 56,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      minimumSize: Size(double.infinity, minHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 0,
    );
  }

  /// Outlined 버튼 스타일
  static ButtonStyle outlinedButton({
    Color? color,
    double borderRadius = 12,
    double borderWidth = 2,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: color ?? AppTheme.lavenderMist,
      side: BorderSide(
        color: color ?? AppTheme.lavenderMist,
        width: borderWidth,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Text 버튼 스타일
  static ButtonStyle textButton({
    Color? color,
  }) {
    return TextButton.styleFrom(
      foregroundColor: color ?? Colors.white70,
    );
  }

  // ==================== Input Decoration ====================

  /// 텍스트 필드 InputDecoration
  static InputDecoration textFieldDecoration({
    String? hintText,
    String? labelText,
    String? suffixText,
    Widget? suffixIcon,
    Color? fillColor,
    Color? focusedBorderColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      hintStyle: TextStyle(color: Colors.grey[600]),
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: fillColor ?? const Color(0xFF1A2332),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: focusedBorderColor ?? AppTheme.lavenderMist,
          width: 2,
        ),
      ),
    );
  }

  // ==================== Dialog Styles ====================

  /// 다이얼로그 배경 색상
  static const Color dialogBackground = Color(0xFF1A2332);

  /// 다이얼로그 Shape
  static RoundedRectangleBorder dialogShape({
    double borderRadius = 20,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // ==================== Spacing ====================

  /// 표준 간격
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 20;
  static const double spacingXXL = 24;

  /// SizedBox 헬퍼
  static Widget verticalSpacing(double height) => SizedBox(height: height);
  static Widget horizontalSpacing(double width) => SizedBox(width: width);

  /// 표준 패딩
  static const EdgeInsets paddingAll = EdgeInsets.all(16);
  static const EdgeInsets paddingAllL = EdgeInsets.all(20);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: 16);

  // ==================== Dividers ====================

  /// 표준 Divider
  static const Divider standardDivider = Divider();

  /// 투명 Divider (간격용)
  static Widget transparentDivider({double height = 20}) {
    return SizedBox(height: height);
  }

  // ==================== Loading Indicators ====================

  /// 로딩 인디케이터 (작은)
  static Widget smallLoading({Color? color}) {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        color: color ?? Colors.white,
        strokeWidth: 2,
      ),
    );
  }

  /// 로딩 인디케이터 (중간)
  static Widget mediumLoading({Color? color}) {
    return CircularProgressIndicator(
      color: color ?? AppTheme.lavenderMist,
    );
  }

  // ==================== Icons ====================

  /// 아이콘 크기 표준
  static const double iconSizeS = 16;
  static const double iconSizeM = 20;
  static const double iconSizeL = 24;
  static const double iconSizeXL = 32;

  // ==================== Shadows ====================

  /// 카드 그림자
  static List<BoxShadow> cardShadow({
    Color? color,
    double blurRadius = 10,
    double spreadRadius = 0,
  }) {
    return [
      BoxShadow(
        color: color ?? Colors.black.withOpacity(0.1),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ==================== Alert/Banner Styles ====================

  /// 성공 배너
  static BoxDecoration successBanner({
    double borderRadius = 12,
  }) {
    return infoCard(
      accentColor: Colors.green,
      borderRadius: borderRadius,
    );
  }

  /// 경고 배너
  static BoxDecoration warningBanner({
    double borderRadius = 12,
  }) {
    return infoCard(
      accentColor: const Color(0xFFFFB74D),
      borderRadius: borderRadius,
    );
  }

  /// 에러 배너
  static BoxDecoration errorBanner({
    double borderRadius = 12,
  }) {
    return infoCard(
      accentColor: Colors.red,
      borderRadius: borderRadius,
    );
  }

  /// 정보 배너
  static BoxDecoration infoBanner({
    double borderRadius = 12,
  }) {
    return infoCard(
      accentColor: AppTheme.infoSoft,
      borderRadius: borderRadius,
    );
  }
}
