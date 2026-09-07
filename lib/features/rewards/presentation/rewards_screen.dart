import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/router/app_routes.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/domain/payout_account.dart';
import '../../../shared/utils/number_format.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
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
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  static final MemberSummary _summary = MemberSummary.placeholder;

  RewardsController? _controller;

  /// The form follows the member's saved wallets; the scope holding them is
  /// not reachable before dependencies are.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= RewardsController(
      availablePoints: _summary.points,
      wallets: AppScope.of(context).payoutAccounts,
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

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;

    return AppScaffold(
      child: ListView(
        padding: AppSpacing.pageInset,
        children: [
          const ScreenHeader(title: 'Cash out'),
          const Gap(AppSpacing.md),
          _BalanceStrip(summary: _summary),
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
                  ),
          ),
          const Gap(AppSpacing.md),
          const SectionHeader(title: 'History'),
          const Gap(AppSpacing.sm),
          const _HistoryCard(),
        ],
      ),
    );
  }
}

class _BalanceStrip extends StatelessWidget {
  const _BalanceStrip({required this.summary});

  final MemberSummary summary;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    child: Wrap(
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
          NumberFormat.points(summary.points),
          style: AppTypography.figtree(size: 20, weight: 800),
        ),
        Text(
          '= ${summary.pesoValue}',
          style: AppTypography.figtree(
            size: 13.5,
            weight: 700,
            color: context.palette.accentText,
          ),
        ),
      ],
    ),
  );
}

class _CashOutForm extends StatelessWidget {
  const _CashOutForm({required this.controller, required this.onOpenWallet});

  final RewardsController controller;

  /// Opens a wallet's form — to add it, or to change what is saved.
  final ValueChanged<PayoutKind> onOpenWallet;

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
        else
          AmountChipRow(
            options: amounts,
            selected: controller.amount,
            onSelect: controller.selectAmount,
          ),
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
          onPressed: controller.canSubmit ? controller.submit : null,
        ),
        const Gap(AppSpacing.sm),
        Text(
          CashOutTerms.feeNote,
          textAlign: TextAlign.center,
          style: AppTypography.figtree(
            size: 13,
            color: context.palette.textFaint,
          ),
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
  const _HistoryCard();

  @override
  Widget build(BuildContext context) => AppCard.flush(
    borderRadius: AppRadius.card,
    child: DividedColumn(
      children: [
        for (final record in CashOutRecord.placeholder)
          _HistoryRow(record: record),
      ],
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
