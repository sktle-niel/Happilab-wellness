import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/google_mark.dart';
import '../../../shared/widgets/inline_action_text.dart';
import '../../../shared/widgets/or_divider.dart';
import 'create_account_controller.dart';
import 'widgets/password_requirement_chips.dart';

/// Join with a referral code — the only way into the programme.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final CreateAccountController _controller = CreateAccountController();

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

  void _backToSignIn() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushReplacementNamed(AppRoutes.signIn);
  }

  void _showProviderUnavailable() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Google sign-up is not connected yet.')),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenInset,
          AppSpacing.md,
          AppSpacing.screenInset,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircleIconButton(
                icon: Icons.arrow_back,
                semanticLabel: 'Back to sign in',
                onPressed: _backToSignIn,
              ),
            ),
            const Gap.sm(),
            const _CreateAccountHeader(),
            const Gap(18),
            AppButton.secondary(
              label: 'Sign up with Google',
              leading: const GoogleMark(),
              onPressed: _showProviderUnavailable,
            ),
            const Gap(AppSpacing.md),
            const OrDivider(),
            const Gap(AppSpacing.md),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => _CreateAccountForm(
                controller: _controller,
                onSubmit: _submit,
              ),
            ),
            const Gap.sm(),
            InlineActionText(
              text: 'Already a member?',
              actionLabel: 'Sign in',
              onPressed: _backToSignIn,
            ),
          ],
        ),
      ),
    ),
  );
}

class _CreateAccountHeader extends StatelessWidget {
  const _CreateAccountHeader();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const BrandMark(size: 72),
      const Gap(4),
      Text('Create account', style: AppTypography.screenTitle),
      const Gap(2),
      Text(
        'Join and start earning from day one',
        style: AppTypography.screenSubtitle,
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _CreateAccountForm extends StatelessWidget {
  const _CreateAccountForm({required this.controller, required this.onSubmit});

  final CreateAccountController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppTextField(
        label: 'Full name',
        controller: controller.fullName,
        hint: 'Ivy C',
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        errorText: controller.fullNameError,
        onChanged: controller.onFullNameChanged,
      ),
      const Gap(AppSpacing.fieldGap),
      AppTextField(
        label: 'Gmail account',
        controller: controller.email,
        hint: 'example@gmail.com',
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        errorText: controller.emailError,
        onChanged: controller.onEmailChanged,
      ),
      const Gap(AppSpacing.fieldGap),
      AppTextField(
        label: 'Password',
        controller: controller.password,
        hint: 'At least 8 characters',
        obscureText: true,
        textInputAction: TextInputAction.next,
        errorText: controller.passwordError,
        onChanged: controller.onPasswordChanged,
      ),
      const Gap(6),
      PasswordRequirementChips(unmetRules: controller.unmetRules),
      const Gap(AppSpacing.fieldGap),
      AppTextField(
        label: 'Referral code',
        requiredNote: '*required',
        controller: controller.referralCode,
        hint: 'e.g. FAITH-MARIA24',
        textInputAction: TextInputAction.done,
        helperText: 'Ask the friend who invited you for their code.',
        errorText: controller.referralCodeError,
        onChanged: controller.onReferralCodeChanged,
        onSubmitted: (_) => onSubmit(),
      ),
      const Gap(AppSpacing.md),
      AppButton(label: 'Create account', onPressed: onSubmit),
    ],
  );
}
