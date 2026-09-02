import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_toast.dart';
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

  void _confirm(String message) => AppToast.success(context, message);

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: ListView(
      padding: AppSpacing.pageInset,
      children: [
        const ScreenHeader(title: 'Edit profile'),
        const Gap(AppSpacing.md),
        _DetailsCard(
          memberName: _summary.name,
          name: _name,
          phone: _phone,
          nameError: _nameError,
          phoneError: _phoneError,
          onSave: _saveDetails,
        ),
        const Gap(AppSpacing.md),
        _PasswordCard(
          current: _currentPassword,
          replacement: _newPassword,
          confirmation: _confirmPassword,
          error: _passwordError,
          onReplacementChanged: () => setState(() {}),
          onSave: _savePassword,
        ),
      ],
    ),
  );
}

/// Who the member is: the avatar, their name and their mobile number.
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.memberName,
    required this.name,
    required this.phone,
    required this.nameError,
    required this.phoneError,
    required this.onSave,
  });

  /// The stored name, which the avatar draws its initials from — not the text
  /// being edited, which changes under the cursor.
  final String memberName;

  final TextEditingController name;
  final TextEditingController phone;
  final String? nameError;
  final String? phoneError;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(child: AvatarCircle(name: memberName, size: 84, bordered: true)),
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
          controller: name,
          hint: 'Your full name',
          style: AppTextFieldStyle.inset,
          textInputAction: TextInputAction.next,
          errorText: nameError,
        ),
        const Gap(12),
        AppTextField(
          label: 'Mobile number',
          controller: phone,
          hint: '+63 9XX XXX XXXX',
          keyboardType: TextInputType.phone,
          style: AppTextFieldStyle.inset,
          textInputAction: TextInputAction.done,
          errorText: phoneError,
        ),
        const Gap(12),
        AppButton(label: 'Save changes', onPressed: onSave),
      ],
    ),
  );
}

/// The password change, with the requirement chips tracking every keystroke.
class _PasswordCard extends StatelessWidget {
  const _PasswordCard({
    required this.current,
    required this.replacement,
    required this.confirmation,
    required this.error,
    required this.onReplacementChanged,
    required this.onSave,
  });

  final TextEditingController current;
  final TextEditingController replacement;
  final TextEditingController confirmation;
  final String? error;
  final VoidCallback onReplacementChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => AppCard(
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
          controller: current,
          hint: '••••••••',
          obscureText: true,
          style: AppTextFieldStyle.inset,
          textInputAction: TextInputAction.next,
        ),
        const Gap(12),
        AppTextField(
          label: 'New password',
          controller: replacement,
          hint: 'At least 8 characters',
          obscureText: true,
          style: AppTextFieldStyle.inset,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onReplacementChanged(),
        ),
        const Gap(6),
        PasswordRequirementChips(
          unmetRules: PasswordPolicy.unmetRules(replacement.text),
        ),
        const Gap(12),
        AppTextField(
          label: 'Confirm new password',
          controller: confirmation,
          hint: 'Repeat new password',
          obscureText: true,
          style: AppTextFieldStyle.inset,
          textInputAction: TextInputAction.done,
          errorText: error,
          onSubmitted: (_) => onSave(),
        ),
        const Gap(12),
        AppButton.secondary(label: 'Update password', onPressed: onSave),
      ],
    ),
  );
}
