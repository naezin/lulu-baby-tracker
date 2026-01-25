import 'package:flutter/material.dart';
import '../../../core/design_system/lulu_design_system.dart';

/// Lulu Design System - SnackBar Component
///
/// 일관된 스타일의 스낵바 유틸리티

enum LuluSnackBarType {
  success,
  warning,
  error,
  info,
}

class LuluSnackBar {
  /// SnackBar 표시
  static void show({
    required BuildContext context,
    required String message,
    LuluSnackBarType type = LuluSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = _getColor(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: LuluTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: LuluRadius.chip),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  /// 성공 SnackBar
  static void success({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: LuluSnackBarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 경고 SnackBar
  static void warning({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: LuluSnackBarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 오류 SnackBar
  static void error({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: LuluSnackBarType.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 정보 SnackBar
  static void info({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      message: message,
      type: LuluSnackBarType.info,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static Color _getColor(LuluSnackBarType type) {
    switch (type) {
      case LuluSnackBarType.success:
        return LuluStatusColors.success;
      case LuluSnackBarType.warning:
        return LuluStatusColors.warning;
      case LuluSnackBarType.error:
        return LuluStatusColors.error;
      case LuluSnackBarType.info:
        return LuluStatusColors.info;
    }
  }

  static IconData _getIcon(LuluSnackBarType type) {
    switch (type) {
      case LuluSnackBarType.success:
        return Icons.check_circle_rounded;
      case LuluSnackBarType.warning:
        return Icons.warning_rounded;
      case LuluSnackBarType.error:
        return Icons.error_rounded;
      case LuluSnackBarType.info:
        return Icons.info_rounded;
    }
  }
}
