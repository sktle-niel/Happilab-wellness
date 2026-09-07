import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/google_mark.dart';
import '../../../shared/widgets/or_divider.dart';
import '../../../shared/widgets/password_requirement_chips.dart';
import 'auth_entry.dart';
import 'create_account_controller.dart';
import 'widgets/auth_sheet.dart';
import 'widgets/password_visibility_toggle.dart';

/// Join with a referral code — the only way into the programme. The first
/// of two steps; the photo follows.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  static const int _step = 1;
  static const int _steps = 2;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final CreateAccountController _controller = CreateAccountController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// No auth backend yet: a valid form starts a persisted local session and
  /// goes on to the photo step, so the member stays signed in across
  /// launches. The repository call that registers the account and returns a
  /// server token replaces the entry helper.
  Future<void> _submit() async {
    if (_isSubmitting || !_controller.validate()) return;
    setState(() => _isSubmitting = true);
    final entered = await enterWithLocalSession(
      context,
      destination: AppRoutes.choosePhoto,
    );
    if (!entered && mounted) setState(() => _isSubmitting = false);
  }

  void _backToSignIn() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushReplacementNamed(AppRoutes.signIn);
  }

  void _showProviderUnavailable() => AppToast.info(
    context,
    'Google sign-up is not connected yet',
    detail: 'Fill the form to join with your referral code.',
  );

  @override
  Widget build(BuildContext context) => AuthSheet(
    title: 'Create account',
    eyebrow:
        'Step ${CreateAccountScreen._step} of ${CreateAccountScreen._steps}'
        ' · Your details',
    progress: CreateAccountScreen._step / CreateAccountScreen._steps,
    onClose: _backToSignIn,
    closeLabel: 'Back to sign in',
    heading: 'Join and start earning from day one',
    helper: 'Fill in your details here; your photo comes next.',
    form: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => _CreateAccountForm(
        controller: _controller,
        onSubmit: _submit,
        onGoogle: _showProviderUnavailable,
        isSubmitting: _isSubmitting,
      ),
    ),
    footer: AuthSheetFooter(
      onCancel: _backToSignIn,
      trailing: Text(
        'Next: your photo',
        style: AppTypography.footnote(context.palette),
      ),
    ),
  );
}

class _CreateAccountForm extends StatelessWidget {
  const _CreateAccountForm({
    required this.controller,
    required this.onSubmit,
    required this.onGoogle,
    required this.isSubmitting,
  });

  final CreateAccountController controller;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppTextField(
        label: 'Full name',
        controller: controller.fullName,
        hint: 'Ivy C',
        leadingIcon: Icons.person_outline_rounded,
        style: AppTextFieldStyle.inset,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        errorText: controller.fullNameError,
        onChanged: controller.onFullNameChanged,
      ),
      const Gap(AppSpacing.fieldGap + 2),
      AppTextField(
        label: 'Gmail account',
        controller: controller.email,
        hint: 'example@gmail.com',
        leadingIcon: Icons.alternate_email_rounded,
        style: AppTextFieldStyle.inset,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        errorText: controller.emailError,
        onChanged: controller.onEmailChanged,
      ),
      const Gap(AppSpacing.fieldGap + 2),
      AppTextField(
        label: 'Password',
        controller: controller.password,
        hint: 'At least 8 characters',
        leadingIcon: Icons.lock_outline_rounded,
        style: AppTextFieldStyle.inset,
        obscureText: controller.isPasswordHidden,
        textInputAction: TextInputAction.next,
        errorText: controller.passwordError,
        onChanged: controller.onPasswordChanged,
        trailing: PasswordVisibilityToggle(
          isHidden: controller.isPasswordHidden,
          onPressed: controller.togglePasswordVisibility,
        ),
      ),
      const Gap(AppSpacing.sm),
      PasswordRequirementChips(unmetRules: controller.unmetRules),
      const Gap(AppSpacing.fieldGap + 2),
      AppTextField(
        label: 'Re-enter your password',
        controller: controller.confirmPassword,
        hint: 'Same as above',
        leadingIcon: Icons.lock_outline_rounded,
        style: AppTextFieldStyle.inset,
        // Follows the field above: one eye reveals both.
        obscureText: controller.isPasswordHidden,
        textInputAction: TextInputAction.next,
        errorText: controller.confirmPasswordError,
        onChanged: controller.onConfirmPasswordChanged,
      ),
      const Gap(AppSpacing.fieldGap + 2),
      AppTextField(
        label: 'Referral code',
        requiredNote: '*required',
        controller: controller.referralCode,
        hint: 'e.g. FCV-MARIA24',
        leadingIcon: Icons.card_giftcard_rounded,
        style: AppTextFieldStyle.inset,
        textInputAction: TextInputAction.done,
        helperText: 'Ask the friend who invited you for their code.',
        errorText: controller.referralCodeError,
        onChanged: controller.onReferralCodeChanged,
        onSubmitted: (_) => onSubmit(),
      ),
      const Gap(AppSpacing.lg),
      AppButton(
        label: 'Create account',
        onPressed: onSubmit,
        isLoading: isSubmitting,
      ),
      const Gap(AppSpacing.md),
      const OrDivider(label: 'or continue with'),
      const Gap(AppSpacing.md),
      AppButton.outlined(
        label: 'Sign up with Google',
        leading: const GoogleMark(),
        onPressed: onGoogle,
      ),
    ],
  );
}
