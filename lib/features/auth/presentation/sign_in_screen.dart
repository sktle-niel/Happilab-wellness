import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/google_mark.dart';
import '../../../shared/widgets/or_divider.dart';
import 'auth_entry.dart';
import 'sign_in_controller.dart';
import 'widgets/auth_sheet.dart';
import 'widgets/password_visibility_toggle.dart';

/// Sign in with an identifier and password, or with a provider.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SignInController _controller = SignInController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The way out of the sheet, when there is one: this screen is also the
  /// root a signed-out member lands on, and then there is nowhere to go.
  VoidCallback? get _back =>
      Navigator.of(context).canPop() ? Navigator.of(context).pop : null;

  /// No auth backend yet: a valid form starts a persisted local session, so
  /// the member stays signed in across launches. The repository call that
  /// exchanges these credentials for a server token replaces the entry helper.
  Future<void> _submit() async {
    if (_isSubmitting || !_controller.validate()) return;
    setState(() => _isSubmitting = true);
    final entered = await enterWithLocalSession(context);
    if (!entered && mounted) setState(() => _isSubmitting = false);
  }

  void _goToCreateAccount() =>
      Navigator.of(context).pushNamed(AppRoutes.createAccount);

  void _showProviderUnavailable() => AppToast.info(
    context,
    'Google sign-in is not connected yet',
    detail: 'Use your username or Gmail and password for now.',
  );

  void _showRecoveryUnavailable() => AppToast.info(
    context,
    'Password reset is not connected yet',
    detail: 'Contact support to reset it for now.',
  );

  @override
  Widget build(BuildContext context) => AuthSheet(
    title: 'Welcome back',
    eyebrow: 'Sign in to continue',
    onClose: _back,
    heading: 'Sign in to keep earning',
    helper: 'Use the username or Gmail you joined with.',
    form: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => _SignInForm(
        controller: _controller,
        onSubmit: _submit,
        onForgotPassword: _showRecoveryUnavailable,
        onGoogle: _showProviderUnavailable,
        isSubmitting: _isSubmitting,
      ),
    ),
    footer: AuthSheetFooter(
      onCancel: _back,
      trailing: TextButton(
        onPressed: _goToCreateAccount,
        child: const Text(
          'Join with a referral code',
          textAlign: TextAlign.end,
        ),
      ),
    ),
  );
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({
    required this.controller,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onGoogle,
    required this.isSubmitting,
  });

  final SignInController controller;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoogle;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppTextField(
        label: 'Username or Gmail',
        controller: controller.identifier,
        hint: 'you@gmail.com',
        leadingIcon: Icons.person_outline_rounded,
        style: AppTextFieldStyle.inset,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        errorText: controller.identifierError,
        onChanged: controller.onIdentifierChanged,
      ),
      const Gap(AppSpacing.fieldGap + 2),
      AppTextField(
        label: 'Password',
        controller: controller.password,
        hint: '••••••••',
        leadingIcon: Icons.lock_outline_rounded,
        style: AppTextFieldStyle.inset,
        obscureText: controller.isPasswordHidden,
        textInputAction: TextInputAction.done,
        errorText: controller.passwordError,
        onChanged: controller.onPasswordChanged,
        onSubmitted: (_) => onSubmit(),
        trailing: PasswordVisibilityToggle(
          isHidden: controller.isPasswordHidden,
          onPressed: controller.togglePasswordVisibility,
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: onForgotPassword,
          child: const Text('Forgot password?'),
        ),
      ),
      const Gap(AppSpacing.sm),
      AppButton(label: 'Sign in', onPressed: onSubmit, isLoading: isSubmitting),
      const Gap(AppSpacing.md),
      const OrDivider(label: 'or continue with'),
      const Gap(AppSpacing.md),
      AppButton.outlined(
        label: 'Continue with Google',
        leading: const GoogleMark(),
        onPressed: onGoogle,
      ),
    ],
  );
}
