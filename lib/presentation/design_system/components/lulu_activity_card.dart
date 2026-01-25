import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';

class LuluActivityCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? backgroundColor;

  const LuluActivityCard({
    Key? key,
    required this.title,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(LuluSpacing.md),
      padding: EdgeInsets.all(LuluSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? LuluColors.surfaceElevated,
        borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusMd),
        border: Border.all(color: LuluColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: LuluSpacing.md),
          child,
        ],
      ),
    );
  }
}
