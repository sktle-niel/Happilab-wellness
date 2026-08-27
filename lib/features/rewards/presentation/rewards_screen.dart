import 'package:flutter/material.dart';

import '../../../app/shell/app_shell_scope.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_colors.dart';
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

/// Turn points into money: how much, where to, and what has already been sent.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  static const MemberSummary _summary = MemberSummary.placeholder;

  final RewardsController _controller = RewardsController(
    availablePoints: _summary.points,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          FaithNavBar.contentInset,
        ),
        children: [
          ScreenHeader(
            showBack: !AppShellScope.contains(context),
            title: 'Cash out',
          ),
          const Gap(AppSpacing.md),
          const _BalanceStrip(summary: _summary),
          const Gap(AppSpacing.md),
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => _controller.isSubmitted
                ? CashOutSuccessCard(
                    message: _controller.confirmation,
                    onDone: _controller.reset,
                  )
                : _CashOutForm(controller: _controller),
          ),
          const Gap(AppSpacing.md),
          const SectionHeader(title: 'History'),
          const Gap(AppSpacing.sm),
          const _HistoryCard(),
        ],
      ),
    ),
  );
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
            color: AppColors.textMuted,
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
            color: AppColors.accentText,
          ),
        ),
      ],
    ),
  );
}

class _CashOutForm extends StatelessWidget {
  const _CashOutForm({required this.controller});

  final RewardsController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionHeader(title: 'Amount'),
      const Gap(AppSpacing.sm),
      AmountChipRow(
        options: controller.amountOptions,
        selected: controller.amount,
        onSelect: controller.selectAmount,
      ),
      const Gap(AppSpacing.md),
      const SectionHeader(title: 'Send to'),
      const Gap(AppSpacing.sm),
      PayoutMethodPicker(
        accounts: PayoutAccount.placeholder,
        selected: controller.destination,
        onSelect: controller.selectDestination,
      ),
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
        style: AppTypography.figtree(size: 13, color: AppColors.textFaint),
      ),
    ],
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
                  color: AppColors.textFaint,
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
