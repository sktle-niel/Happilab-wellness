import 'package:flutter/material.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/security/input_validator.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/domain/password_policy.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/avatar_circle.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/password_requirement_chips.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../app/theme/app_palette.dart';

/// Change the details on the account, and the password that guards it.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const MemberSummary _summary = MemberSummary.placeholder;

  final TextEditingController _name = TextEditingController(
    text: _summary.name,
  );
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _saveDetails() {
    setState(() {
      _nameError = InputValidator.notEmpty(
        InputValidator.sanitize(_name.text),
        field: 'Full name',
      );
      _phoneError = InputValidator.minLength(
        InputValidator.sanitize(_phone.text),
        11,
        field: 'Mobile number',
      );
    });
    if (_nameError != null || _phoneError != null) return;
    _confirm('Profile saved.');
  }

  void _savePassword() {
    setState(() => _passwordError = _validatePasswordChange());
    if (_passwordError != null) return;
    _confirm('Password updated.');
  }

  /// The first thing wrong with the password change, or null if nothing is.
  String? _validatePasswordChange() {
    if (_currentPassword.text.isEmpty) return 'Enter your current password.';
    if (!PasswordPolicy.isValid(_newPassword.text)) {
      return PasswordPolicy.validate(_newPassword.text);
    }
    if (_newPassword.text != _confirmPassword.text) {
      return 'The two new passwords do not match.';
    }
    return null;
  }

  void _confirm(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.palette.canvas,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const ScreenHeader(title: 'Edit profile'),
          const Gap(AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: AvatarCircle(
                    name: _summary.name,
                    size: 84,
                    bordered: true,
                  ),
                ),
                const Gap(12),
                Text(
                  'Photo upload is not connected yet.',
                  textAlign: TextAlign.center,
                  style: AppTypography.figtree(
                    size: 11.5,
                    color: context.palette.textFaint,
                  ),
                ),
                const Gap(12),
                AppTextField(
                  label: 'Full name',
                  controller: _name,
                  hint: 'Your full name',
                  style: AppTextFieldStyle.inset,
                  textInputAction: TextInputAction.next,
                  errorText: _nameError,
                ),
                const Gap(12),
                AppTextField(
                  label: 'Mobile number',
                  controller: _phone,
                  hint: '+63 9XX XXX XXXX',
                  keyboardType: TextInputType.phone,
                  style: AppTextFieldStyle.inset,
                  textInputAction: TextInputAction.done,
                  errorText: _phoneError,
                ),
                const Gap(12),
                AppButton(label: 'Save changes', onPressed: _saveDetails),
              ],
            ),
          ),
          const Gap(AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Change password',
                  style: AppTypography.figtree(size: 16, weight: 800),
                ),
                const Gap(12),
                AppTextField(
                  label: 'Current password',
                  controller: _currentPassword,
                  hint: '••••••••',
                  obscureText: true,
                  style: AppTextFieldStyle.inset,
                  textInputAction: TextInputAction.next,
                ),
                const Gap(12),
                AppTextField(
                  label: 'New password',
                  controller: _newPassword,
                  hint: 'At least 8 characters',
                  obscureText: true,
                  style: AppTextFieldStyle.inset,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
                const Gap(6),
                PasswordRequirementChips(
                  unmetRules: PasswordPolicy.unmetRules(_newPassword.text),
                ),
                const Gap(12),
                AppTextField(
                  label: 'Confirm new password',
                  controller: _confirmPassword,
                  hint: 'Repeat new password',
                  obscureText: true,
                  style: AppTextFieldStyle.inset,
                  textInputAction: TextInputAction.done,
                  errorText: _passwordError,
                  onSubmitted: (_) => _savePassword(),
                ),
                const Gap(12),
                AppButton.secondary(
                  label: 'Update password',
                  onPressed: _savePassword,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
