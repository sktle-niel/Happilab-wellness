import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/google_mark.dart';
import '../../../shared/widgets/inline_action_text.dart';
import '../../../shared/widgets/or_divider.dart';
import 'sign_in_controller.dart';

/// Sign in with a provider or with an identifier and password.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SignInController _controller = SignInController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_controller.validate()) return;
    // No auth backend yet: a valid form goes straight through. Swap this for a
    // repository call once the API exists.
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _showProviderUnavailable() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Google sign-in is not connected yet.')),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenInset,
          56,
          AppSpacing.screenInset,
          50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SignInHeader(),
            const Gap(22),
            AppButton.secondary(
              label: 'Continue with Google',
              leading: const GoogleMark(),
              onPressed: _showProviderUnavailable,
            ),
            const Gap(18),
            const OrDivider(),
            const Gap(18),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) =>
                  _SignInForm(controller: _controller, onSubmit: _submit),
            ),
            const Gap.sm(),
            InlineActionText(
              text: 'No account yet?',
              actionLabel: 'Join with a referral code',
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.createAccount),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SignInHeader extends StatelessWidget {
  const _SignInHeader();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const BrandMark(),
      const Gap(6),
      Text('Welcome back', style: AppTypography.screenTitle),
      const Gap(2),
      Text('Sign in to keep earning', style: AppTypography.screenSubtitle),
    ],
  );
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({required this.controller, required this.onSubmit});

  final SignInController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppTextField(
        label: 'Username or Gmail',
        controller: controller.identifier,
        hint: 'you@gmail.com',
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        errorText: controller.identifierError,
        onChanged: controller.onIdentifierChanged,
      ),
      const Gap(AppSpacing.fieldGap),
      AppTextField(
        label: 'Password',
        controller: controller.password,
        hint: '••••••••',
        obscureText: controller.isPasswordHidden,
        textInputAction: TextInputAction.done,
        errorText: controller.passwordError,
        onChanged: controller.onPasswordChanged,
        onSubmitted: (_) => onSubmit(),
        trailing: _PasswordVisibilityToggle(controller: controller),
      ),
      const Gap(AppSpacing.md),
      AppButton(label: 'Sign in', onPressed: onSubmit),
    ],
  );
}

class _PasswordVisibilityToggle extends StatelessWidget {
  const _PasswordVisibilityToggle({required this.controller});

  final SignInController controller;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: controller.togglePasswordVisibility,
    icon: Icon(
      controller.isPasswordHidden
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
      size: 17,
      color: AppColors.textFaint,
    ),
    tooltip: controller.isPasswordHidden ? 'Show password' : 'Hide password',
    splashRadius: 20,
  );
}
