import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/security/input_validator.dart';
import '../../../shared/domain/payout_account.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../app/theme/app_palette.dart';

/// Update the account a payout method sends to.
///
/// Takes the [kind] as an argument so one screen serves every method, rather
/// than one screen per wallet.
class EditPayoutNumberScreen extends StatefulWidget {
  const EditPayoutNumberScreen({this.kind = PayoutKind.gcash, super.key});

  final PayoutKind kind;

  @override
  State<EditPayoutNumberScreen> createState() => _EditPayoutNumberScreenState();
}

class _EditPayoutNumberScreenState extends State<EditPayoutNumberScreen> {
  final TextEditingController _accountName = TextEditingController();
  final TextEditingController _reference = TextEditingController();

  static const String _referenceLabel = 'Mobile number';

  /// A Philippine mobile number: 09XX XXX XXXX.
  static const int _mobileNumberLength = 11;

  String? _accountNameError;
  String? _referenceError;

  @override
  void dispose() {
    _accountName.dispose();
    _reference.dispose();
    super.dispose();
  }

  void _save() {
    final name = InputValidator.sanitize(_accountName.text);
    final reference = InputValidator.sanitize(_reference.text);

    setState(() {
      _accountNameError = InputValidator.notEmpty(name, field: 'Account name');
      _referenceError = InputValidator.minLength(
        reference,
        _mobileNumberLength,
        field: _referenceLabel,
      );
    });

    if (_accountNameError != null || _referenceError != null) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: ListView(
      padding: AppSpacing.pageInset,
      children: [
        ScreenHeader(title: 'Update ${widget.kind.label}'),
        const Gap(AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Account name',
                controller: _accountName,
                hint: 'Full name on the account',
                style: AppTextFieldStyle.inset,
                textInputAction: TextInputAction.next,
                errorText: _accountNameError,
              ),
              const Gap(12),
              AppTextField(
                label: _referenceLabel,
                controller: _reference,
                hint: '09XX XXX XXXX',
                keyboardType: TextInputType.phone,
                style: AppTextFieldStyle.inset,
                textInputAction: TextInputAction.done,
                errorText: _referenceError,
                onSubmitted: (_) => _save(),
              ),
              const Gap(12),
              Text(
                'Make sure the account is under your name — payouts to '
                'accounts belonging to other people are not allowed.',
                style: AppTypography.figtree(
                  size: 11.5,
                  color: context.palette.textFaint,
                ),
              ),
              const Gap(12),
              AppButton(label: 'Save number', onPressed: _save),
            ],
          ),
        ),
      ],
    ),
  );
}
