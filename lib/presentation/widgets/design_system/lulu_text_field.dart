import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design_system/lulu_design_system.dart';

/// Lulu Design System - TextField Component
///
/// 일관된 스타일의 입력 필드 컴포넌트

class LuluTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const LuluTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      enabled: enabled,
      style: LuluTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: LuluTextStyles.bodyMedium,
        hintStyle: LuluTextStyles.bodyMedium.copyWith(
          color: LuluTextColors.tertiary,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: LuluTextColors.secondary)
            : null,
        suffix: suffix,
        filled: true,
        fillColor: LuluColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: LuluRadius.input,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: LuluRadius.input,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: LuluRadius.input,
          borderSide: const BorderSide(
            color: LuluColors.lavenderMist,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: LuluRadius.input,
          borderSide: BorderSide(
            color: LuluStatusColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: LuluRadius.input,
          borderSide: BorderSide(
            color: LuluStatusColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: LuluRadius.input,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

/// Number TextField - 숫자 입력 전용
class LuluNumberField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? min;
  final int? max;
  final bool allowDecimal;

  const LuluNumberField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.onChanged,
    this.min,
    this.max,
    this.allowDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return LuluTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      suffix: suffix != null ? Text(suffix!) : null,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}
