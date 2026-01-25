import 'package:flutter/material.dart';
import '../../../core/design_system/lulu_design_system.dart';

/// Lulu Design System - Card Component
///
/// 일관된 스타일의 카드 컴포넌트

class LuluCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool glassmorphism;
  final Color? backgroundColor;
  final Color? borderColor;

  const LuluCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glassmorphism = false,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding ?? LuluSpacing.cardPadding,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (glassmorphism
                ? LuluColors.glassBackground
                : LuluColors.surfaceCard),
        borderRadius: LuluRadius.card,
        border: Border.all(
          color: borderColor ??
              (glassmorphism
                  ? LuluColors.glassBorder
                  : Colors.transparent),
          width: 1,
        ),
        boxShadow: glassmorphism ? LuluShadows.glassmorphism : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: LuluRadius.card,
        child: container,
      );
    }

    return container;
  }
}

/// Activity Card - 활동별 색상 카드
class LuluActivityCard extends StatelessWidget {
  final Widget child;
  final String activityType;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const LuluActivityCard({
    super.key,
    required this.child,
    required this.activityType,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = LuluActivityColors.forType(activityType);

    return LuluCard(
      padding: padding,
      onTap: onTap,
      backgroundColor: LuluColors.surfaceCard,
      borderColor: color.withOpacity(0.3),
      child: child,
    );
  }
}
