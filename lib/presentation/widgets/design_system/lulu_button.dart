import 'package:flutter/material.dart';
import '../../../core/design_system/lulu_design_system.dart';

/// Lulu Design System - Button Component
///
/// 일관된 스타일의 버튼 컴포넌트

enum LuluButtonStyle {
  /// Primary 버튼 (라벤더 배경)
  primary,

  /// Secondary 버튼 (어두운 배경)
  secondary,

  /// Outline 버튼 (투명 배경 + 테두리)
  outline,
}

class LuluButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final LuluButtonStyle style;
  final bool fullWidth;

  const LuluButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.style = LuluButtonStyle.primary,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(
                    _getLoadingColor(),
                  ),
                ),
              )
            : Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: LuluTextStyles.labelLarge.copyWith(
                      color: _getTextColor(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (style) {
      case LuluButtonStyle.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: LuluColors.lavenderMist,
          foregroundColor: LuluColors.midnightNavy,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: LuluRadius.button,
          ),
        );
      case LuluButtonStyle.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: LuluColors.surfaceElevated,
          foregroundColor: LuluTextColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: LuluRadius.button,
          ),
        );
      case LuluButtonStyle.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: LuluColors.lavenderMist,
          elevation: 0,
          side: const BorderSide(color: LuluColors.lavenderMist, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: LuluRadius.button,
          ),
        );
    }
  }

  Color _getTextColor() {
    switch (style) {
      case LuluButtonStyle.primary:
        return LuluColors.midnightNavy;
      case LuluButtonStyle.secondary:
        return LuluTextColors.primary;
      case LuluButtonStyle.outline:
        return LuluColors.lavenderMist;
    }
  }

  Color _getLoadingColor() {
    switch (style) {
      case LuluButtonStyle.primary:
        return LuluColors.midnightNavy;
      case LuluButtonStyle.secondary:
        return LuluTextColors.primary;
      case LuluButtonStyle.outline:
        return LuluColors.lavenderMist;
    }
  }
}

/// Activity Button - 활동별 색상 버튼
class LuluActivityButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final String activityType; // 'sleep', 'feeding', 'diaper', 'play', 'health'
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const LuluActivityButton({
    super.key,
    required this.label,
    required this.activityType,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = LuluActivityColors.forType(activityType);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: LuluRadius.button,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: LuluTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
