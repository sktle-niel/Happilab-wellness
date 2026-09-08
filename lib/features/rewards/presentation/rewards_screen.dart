import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/router/app_routes.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/list_skeleton.dart';
import '../../../shared/widgets/member_view.dart';
import '../../../shared/widgets/repository_view.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../core/storage/persisted_flag.dart';
import '../../../shared/domain/payout_account.dart';
import '../../../shared/utils/number_format.dart';
import '../../../shared/widgets/balance_eye.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/cash_out.dart';
import 'rewards_controller.dart';
import 'widgets/amount_chip_row.dart';
import 'widgets/cash_out_success_card.dart';
import 'widgets/payout_method_picker.dart';
import '../../../app/theme/app_palette.dart';

/// Turn points into money: how much, where to, and what has already been sent.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: MemberView(
      builder: (context, member) => _RewardsBody(member: member),
    ),
  );
}

/// The form and the history, once the balance is known.
class _RewardsBody extends StatefulWidget {
  const _RewardsBody({required this.member});

  final MemberSummary member;

  @override
  State<_RewardsBody> createState() => _RewardsBodyState();
}

class _RewardsBodyState extends State<_RewardsBody> {
  RewardsController? _controller;

  /// The form follows the member's saved wallets; the scope holding them is
  /// not reachable before dependencies are.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dependencies = AppScope.of(context);
    dependencies.payoutAccounts.load();
    _controller ??= RewardsController(
      availablePoints: widget.member.points,
      wallets: dependencies.payoutAccounts,
      rewards: dependencies.repositories.rewards,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// One form adds and edits: it opens on whatever is saved for the wallet.
  void _openWallet(PayoutKind kind) =>
      Navigator.of(context)
          .pushNamed(AppRoutes.editPayoutNumber, arguments: kind);

  /// A refusal is said in a toast; the form stays as it was for another go.
  Future<void> _submit() async {
    final overlay = Overlay.of(context);
    final error = await _controller!.submit();
    if (error != null) AppToast.failureOn(overlay, error);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;

    return ListView(
      padding: AppSpacing.pageInset,
      children: [
        const ScreenHeader(title: 'Cash out'),
        const Gap(AppSpacing.md),
        _BalanceStrip(
          summary: widget.member,
          hidden: AppScope.of(context).balanceHidden,
        ),
        const Gap(AppSpacing.sm),
        const _CashOutNote(),
        const Gap(AppSpacing.md),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => controller.isSubmitted
              ? CashOutSuccessCard(
                  message: controller.confirmation,
                  onDone: controller.reset,
                )
              : _CashOutForm(
                  controller: controller,
                  onOpenWallet: _openWallet,
                  onSubmit: _submit,
                ),
        ),
        const Gap(AppSpacing.md),
        const SectionHeader(title: 'History'),
        const Gap(AppSpacing.sm),
        RepositoryView<List<CashOutRecord>>(
          read: (repositories) => repositories.rewards.history(),
          skeleton: const ListSkeleton(rows: 2, withAvatar: false),
          builder: (context, records) => _HistoryCard(records: records),
        ),
      ],
    );
  }
}

class _BalanceStrip extends StatelessWidget {
  const _BalanceStrip({required this.summary, required this.hidden});

  final MemberSummary summary;
  final PersistedFlag hidden;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.fromLTRB(18, 10, 8, 10),
    child: ListenableBuilder(
      listenable: hidden,
      builder: (context, _) => Row(
        children: [
          Expanded(
            child: _BalanceFigures(summary: summary, isHidden: hidden.value),
          ),
          BalanceEye(hidden: hidden, color: context.palette.textMuted),
        ],
      ),
    ),
  );
}

class _BalanceFigures extends StatelessWidget {
  const _BalanceFigures({required this.summary, required this.isHidden});

  final MemberSummary summary;
  final bool isHidden;

  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 10,
    runSpacing: 4,
    children: [
      Text(
        'Available',
        style: AppTypography.figtree(
          size: 12.5,
          weight: 700,
          color: context.palette.textMuted,
        ),
      ),
      Text(
        '${summary.pointsShown(hidden: isHidden)} pts',
        style: AppTypography.figtree(size: 20, weight: 800),
      ),
      Text(
        '= ${summary.pesoShown(hidden: isHidden)}',
        style: AppTypography.figtree(
          size: 13.5,
          weight: 700,
          color: context.palette.accentText,
        ),
      ),
    ],
  );
}

class _CashOutForm extends StatelessWidget {
  const _CashOutForm({
    required this.controller,
    required this.onOpenWallet,
    required this.onSubmit,
  });

  final RewardsController controller;

  /// Opens a wallet's form — to add it, or to change what is saved.
  final ValueChanged<PayoutKind> onOpenWallet;
  final VoidCallback onSubmit;

  /// Inert until the form is complete, and while a request is out.
  VoidCallback? get _onPressed =>
      controller.canSubmit && !controller.isSubmitting ? onSubmit : null;

  @override
  Widget build(BuildContext context) {
    final amounts = controller.amountOptions;
    final accounts = controller.accounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Amount'),
        const Gap(AppSpacing.sm),
        if (amounts.isEmpty)
          const _NotEnoughToSend()
        else ...[
          AmountChipRow(
            options: amounts,
            selected: controller.amount,
            onSelect: controller.selectAmount,
          ),
          const Gap(AppSpacing.sm + 4),
          _CustomAmountField(controller: controller),
        ],
        const Gap(AppSpacing.md),
        const SectionHeader(title: 'Send to'),
        const Gap(AppSpacing.sm),
        if (accounts.isEmpty)
          _NoWalletYet(onAdd: onOpenWallet)
        else
          PayoutMethodPicker(
            accounts: accounts,
            selected: controller.destination,
            onSelect: controller.selectDestination,
            onEdit: onOpenWallet,
          ),
        if (accounts.isNotEmpty)
          for (final kind in controller.missingKinds) ...[
            const Gap(AppSpacing.sm),
            _AddWalletButton(kind: kind, onPressed: onOpenWallet),
          ],
        const Gap(AppSpacing.md),
        AppButton(
          label: controller.amount == null
              ? 'Choose an amount'
              : 'Cash out ${NumberFormat.peso(controller.amount!)}',
          onPressed: _onPressed,
          isLoading: controller.isSubmitting,
        ),
      ],
    );
  }
}

/// Stands in for the picker while no wallet is saved: what is missing, and
/// the way to add it — a cash out has nowhere to go until then.
class _NoWalletYet extends StatelessWidget {
  const _NoWalletYet({required this.onAdd});

  final ValueChanged<PayoutKind> onAdd;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No payout account yet',
          style: AppTypography.figtree(size: 15, weight: 800),
        ),
        const Gap(4),
        Text(
          'Add the wallet your cash outs should go to.',
          style: AppTypography.figtree(
            size: 13.5,
            color: context.palette.textMuted,
          ),
        ),
        const Gap(14),
        for (final kind in PayoutKind.values) ...[
          if (kind != PayoutKind.values.first) const Gap(AppSpacing.sm),
          _AddWalletButton(kind: kind, onPressed: onAdd),
        ],
      ],
    ),
  );
}

class _AddWalletButton extends StatelessWidget {
  const _AddWalletButton({required this.kind, required this.onPressed});

  final PayoutKind kind;
  final ValueChanged<PayoutKind> onPressed;

  @override
  Widget build(BuildContext context) => AppButton.outlined(
    label: 'Add ${kind.label}',
    icon: Icons.add_rounded,
    onPressed: () => onPressed(kind),
  );
}

/// The one rule of cashing out, said before the form: the balance it takes.
class _CashOutNote extends StatelessWidget {
  const _CashOutNote();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icon(
          Icons.info_outline_rounded,
          size: 17,
          color: context.palette.accentText,
        ),
      ),
      const Gap.sm(),
      Expanded(
        child: Text(
          CashOutTerms.requirementNote,
          style: AppTypography.figtree(
            size: 13,
            weight: 600,
            height: 1.4,
            color: context.palette.textMuted,
          ),
        ),
      ),
    ],
  );
}

/// An amount of the member's own, checked as it is typed. Only offered once
/// the balance can be sent at all.
class _CustomAmountField extends StatelessWidget {
  const _CustomAmountField({required this.controller});

  final RewardsController controller;

  @override
  Widget build(BuildContext context) => AppTextField(
    label: 'Or enter an amount',
    controller: controller.customAmount,
    hint: 'e.g. 1500',
    leadingIcon: Icons.edit_outlined,
    style: AppTextFieldStyle.inset,
    keyboardType: TextInputType.number,
    textInputAction: TextInputAction.done,
    helperText:
        'From ${NumberFormat.points(CashOutTerms.minimumPoints)} up to your '
        'balance.',
    errorText: controller.customAmountError,
    onChanged: controller.onCustomAmountChanged,
    trailing: Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Text(
        'pts',
        style: AppTypography.figtree(
          size: 13,
          weight: 700,
          color: context.palette.textFaint,
        ),
      ),
    ),
  );
}

/// Stands in for the amount chips when the balance is below the minimum. An
/// empty row under the heading reads as a screen that failed to load.
class _NotEnoughToSend extends StatelessWidget {
  const _NotEnoughToSend();

  @override
  Widget build(BuildContext context) => Text(
    CashOutTerms.belowMinimumNote,
    style: AppTypography.figtree(size: 13.5, color: context.palette.textMuted),
  );
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.records});

  final List<CashOutRecord> records;

  @override
  Widget build(BuildContext context) => AppCard.flush(
    borderRadius: AppRadius.card,
    child: DividedColumn(
      children: [for (final record in records) _HistoryRow(record: record)],
    ),
  );
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.record});

  final CashOutRecord record;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                record.destination,
                style: AppTypography.figtree(size: 14.5),
              ),
              Text(
                record.when,
                style: AppTypography.figtree(
                  size: 12,
                  color: context.palette.textFaint,
                ),
              ),
            ],
          ),
        ),
        Text(
          record.amountLabel,
          style: AppTypography.figtree(size: 14.5, weight: 800),
        ),
      ],
    ),
  );
}
