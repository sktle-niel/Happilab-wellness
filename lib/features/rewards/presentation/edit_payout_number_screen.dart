import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/payout_account.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import 'payout_account_form.dart';

/// Add or update the account a payout wallet sends to.
///
/// Takes the [kind] as a route argument so one screen serves every wallet,
/// rather than one screen per wallet.
class EditPayoutNumberScreen extends StatefulWidget {
  const EditPayoutNumberScreen({required this.kind, super.key});

  final PayoutKind kind;

  /// The wallet the route was opened for; GCash when none was named.
  static PayoutKind kindFrom(Object? arguments) =>
      arguments is PayoutKind ? arguments : PayoutKind.gcash;

  @override
  State<EditPayoutNumberScreen> createState() => _EditPayoutNumberScreenState();
}

class _EditPayoutNumberScreenState extends State<EditPayoutNumberScreen> {
  PayoutAccountForm? _form;

  PayoutAccounts get _wallets => AppScope.of(context).payoutAccounts;

  /// Opens on what is saved for the wallet; the scope is not reachable
  /// before dependencies are.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _form ??= PayoutAccountForm(
      kind: widget.kind,
      existing: _wallets.forKind(widget.kind),
    );
  }

  @override
  void dispose() {
    _form?.dispose();
    super.dispose();
  }

  String get _title =>
      '${_form!.isNew ? 'Add' : 'Update'} ${widget.kind.label}';

  void _save() {
    final account = _form!.submit();
    if (account == null) return;
    _wallets.save(account);
    AppToast.success(context, '${account.label} account saved');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final form = _form!;

    return AppScaffold(
      child: ListView(
        padding: AppSpacing.pageInset,
        children: [
          ScreenHeader(title: _title),
          const Gap(AppSpacing.md),
          AppCard(
            child: ListenableBuilder(
              listenable: form,
              builder: (context, _) =>
                  _AccountFields(form: form, onSave: _save),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountFields extends StatelessWidget {
  const _AccountFields({required this.form, required this.onSave});

  final PayoutAccountForm form;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      AppTextField(
        label: 'Account name',
        controller: form.accountName,
        hint: 'Full name on the account',
        leadingIcon: Icons.person_outline_rounded,
        style: AppTextFieldStyle.inset,
        textInputAction: TextInputAction.next,
        errorText: form.accountNameError,
        onChanged: form.onAccountNameChanged,
      ),
      const Gap(12),
      AppTextField(
        label: 'Mobile number',
        controller: form.number,
        hint: '09XX XXX XXXX',
        leadingIcon: Icons.phone_iphone_rounded,
        keyboardType: TextInputType.phone,
        style: AppTextFieldStyle.inset,
        textInputAction: TextInputAction.done,
        errorText: form.numberError,
        onChanged: form.onNumberChanged,
        onSubmitted: (_) => onSave(),
      ),
      const Gap(12),
      Text(
        'Make sure the account is under your name — payouts to accounts '
        'belonging to other people are not allowed.',
        style: AppTypography.figtree(
          size: 11.5,
          color: context.palette.textFaint,
        ),
      ),
      const Gap(12),
      AppButton(label: 'Save account', onPressed: onSave),
    ],
  );
}
