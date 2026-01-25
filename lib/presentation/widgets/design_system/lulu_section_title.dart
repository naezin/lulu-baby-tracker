import 'package:flutter/material.dart';
import '../../../core/design_system/lulu_design_system.dart';

/// Lulu Design System - Section Title Component
///
/// 일관된 스타일의 섹션 제목 컴포넌트

class LuluSectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? icon;

  const LuluSectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: LuluColors.lavenderMist,
                  size: LuluIcons.sizeSM,
                ),
                const SizedBox(width: 8),
              ],
              Text(title, style: LuluTextStyles.titleMedium),
            ],
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: LuluTextStyles.bodyMedium.copyWith(
                  color: LuluColors.lavenderMist,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
