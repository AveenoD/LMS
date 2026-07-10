import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/theme/app_spacing.dart';

class InputField extends StatefulWidget {
  final String label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? helperText;
  final String? errorText;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const InputField({
    Key? key,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.helperText,
    this.errorText,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            obscureText: _isObscured,
            keyboardType: widget.keyboardType,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            validator: widget.validator,
            style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: AppText.labelSm.copyWith(color: AppColors.textSecond),
              floatingLabelStyle: AppText.labelSm.copyWith(color: AppColors.chalkTeal),
              filled: true,
              fillColor: AppColors.paper,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppColors.inkGreen.withValues(alpha: 0.5))
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecond,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    )
                  : widget.suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.chalkTeal, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.redInk, width: 1.5),
              ),
            ),
          ),
          if (widget.helperText != null || widget.errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.errorText ?? widget.helperText!,
              style: AppText.caption.copyWith(
                color: widget.errorText != null ? AppColors.redInk : AppColors.textSecond,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DropdownField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? value;
  final String Function(T) itemLabelBuilder;
  final void Function(T?) onChanged;

  const DropdownField({
    Key? key,
    required this.label,
    required this.items,
    required this.value,
    required this.itemLabelBuilder,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SizedBox(
        height: 52,
        child: DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabelBuilder(item),
                style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.expand_more, color: AppColors.textSecond),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppText.labelSm.copyWith(color: AppColors.textSecond),
            floatingLabelStyle: AppText.labelSm.copyWith(color: AppColors.chalkTeal),
            filled: true,
            fillColor: AppColors.paper,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.chalkTeal, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
