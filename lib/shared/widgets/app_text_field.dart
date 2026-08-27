import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';

/// Labelled input used by every form in the app.
///
/// Validation state arrives as [errorText] rather than being computed here: the
/// screen's controller owns the rules, the field only renders them.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.requiredNote,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helperText;
  final String? errorText;

  /// Small red note beside the label, e.g. `*required`.
  final String? requiredNote;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_hasFocus == _focusNode.hasFocus) return;
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: widget.label, requiredNote: widget.requiredNote),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: AppSpacing.inputHeight,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.input,
            boxShadow: AppShadows.input,
            border: Border.all(
              color: hasError
                  ? AppColors.danger
                  : _hasFocus
                  ? AppColors.focus
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  obscureText: widget.obscureText,
                  style: AppTypography.input,
                  cursorColor: AppColors.accent,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: AppTypography.input.copyWith(
                      color: AppColors.textFaint,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
        if (hasError || widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText ?? widget.helperText!,
            style: hasError
                ? AppTypography.helper.copyWith(color: AppColors.danger)
                : AppTypography.helper,
          ),
        ],
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.requiredNote});

  final String label;
  final String? requiredNote;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: label.toUpperCase(),
      style: AppTypography.fieldLabel,
      children: [
        if (requiredNote != null)
          TextSpan(
            text: ' $requiredNote',
            style: AppTypography.figtree(
              size: 11,
              weight: 800,
              color: AppColors.danger,
            ),
          ),
      ],
    ),
  );
}
