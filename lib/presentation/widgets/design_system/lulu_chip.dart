import 'package:flutter/material.dart';
import '../../../core/design_system/lulu_design_system.dart';

/// Lulu Design System - Chip Component
///
/// 일관된 스타일의 선택 칩 컴포넌트

class LuluChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const LuluChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.emoji,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? LuluColors.lavenderMist;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: LuluSpacing.chipPadding,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : LuluColors.surfaceElevated,
          borderRadius: LuluRadius.chip,
          border: Border.all(
            color: isSelected
                ? color
                : LuluColors.softBlue.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: LuluTextStyles.bodyMedium.copyWith(
                color: isSelected ? color : LuluTextColors.secondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity Chip - 활동별 색상 칩
class LuluActivityChip extends StatelessWidget {
  final String label;
  final String activityType;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const LuluActivityChip({
    super.key,
    required this.label,
    required this.activityType,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = LuluActivityColors.forType(activityType);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: LuluSpacing.chipPadding,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : LuluColors.surfaceElevated,
          borderRadius: LuluRadius.chip,
          border: Border.all(
            color: isSelected
                ? color
                : LuluColors.softBlue.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? color : LuluTextColors.secondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: LuluTextStyles.bodyMedium.copyWith(
                color: isSelected ? color : LuluTextColors.secondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
