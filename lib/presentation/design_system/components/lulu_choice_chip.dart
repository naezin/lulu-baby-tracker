import 'package:flutter/material.dart';
import '../tokens/spacing.dart';

class LuluChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? activityColor;

  const LuluChoiceChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.activityColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: activityColor?.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusSm),
      ),
    );
  }
}
