import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/domain/payout_account.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/avatar_circle.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/icon_pill_button.dart';
import '../../../shared/widgets/pressable_scale.dart';
import '../../../shared/widgets/section_header.dart';
import 'widgets/payout_method_card.dart';
import 'widgets/settings_row.dart';

/// Who the member is, where their money goes, and everything else.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  /// The programme caps linked destinations, and the design says so on screen.
  static const int maxPayoutMethods = 3;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const MemberSummary _summary = MemberSummary.placeholder;

  List<PayoutAccount> _payouts = PayoutAccount.placeholder;
  bool _notificationsEnabled = true;

  bool get _canAddPayout => _payouts.length < ProfileScreen.maxPayoutMethods;

  void _removePayout(PayoutAccount account) => setState(
    () => _payouts = [
      for (final entry in _payouts)
        if (entry != account) entry,
    ],
  );

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
          Text(
            'Profile',
            style: AppTypography.figtree(
              size: 25,
              weight: 800,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(AppSpacing.md),
          _IdentityCard(
            summary: _summary,
            onEdit: () =>
                Navigator.of(context).pushNamed(AppRoutes.editProfile),
          ),
          const Gap(AppSpacing.md),
          const SectionHeader(title: 'Payout methods'),
          const Gap(AppSpacing.sm),
          if (_payouts.isEmpty)
            _NoPayoutsCard(onAdd: _openAddPayout)
          else
            for (final account in _payouts) ...[
              PayoutMethodCard(
                account: account,
                onEdit: () =>
                    Navigator.of(context).pushNamed(AppRoutes.editPayoutNumber),
                onRemove: () => _removePayout(account),
              ),
              const Gap.sm(),
            ],
          if (_canAddPayout) ...[
            _AddPayoutRow(onPressed: _openAddPayout),
            const Gap.sm(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'You can link up to ${ProfileScreen.maxPayoutMethods} payout '
                'methods.',
                style: AppTypography.figtree(
                  size: 11.5,
                  color: AppColors.textFaint,
                ),
              ),
            ),
          ],
          const Gap(AppSpacing.md),
          const SectionHeader(title: 'Settings'),
          const Gap(AppSpacing.sm),
          AppCard.flush(
            borderRadius: AppRadius.card,
            child: DividedColumn(
              children: [
                SettingsToggleRow(
                  label: 'Notifications',
                  value: _notificationsEnabled,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                const SettingsValueRow(label: 'Language', value: 'English'),
                SettingsLinkRow(
                  label: 'Account activity',
                  onPressed: () =>
                      Navigator.of(context)
                          .pushNamed(AppRoutes.accountActivity),
                ),
                SettingsLinkRow(
                  label: 'Help center',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.helpCenter),
                ),
                SettingsLinkRow(
                  label: 'Terms & privacy',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.terms),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.md),
          _LogOutButton(
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false),
          ),
        ],
      ),
    ),
  );

  Future<void> _openAddPayout() async {
    final bank = await Navigator.of(context)
        .pushNamed<Object?>(AppRoutes.addPayoutMethod);
    if (!mounted || bank is! String) return;
    setState(
      () => _payouts = [
        ..._payouts,
        PayoutAccount(
          kind: PayoutKind.bank,
          accountName: _summary.name,
          reference: bank,
        ),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.summary, required this.onEdit});

  final MemberSummary summary;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => AppCard(
    borderRadius: AppRadius.hero,
    child: Row(
      children: [
        AvatarCircle(name: summary.name, size: 62, bordered: true),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.name,
                style: AppTypography.figtree(size: 17.5, weight: 800),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Code: ${summary.referralCode}',
                style: AppTypography.figtree(
                  size: 13,
                  weight: 800,
                  color: AppColors.accentText,
                ),
              ),
            ],
          ),
        ),
        const Gap.sm(),
        IconPillButton(
          label: 'Edit',
          icon: Icons.edit_outlined,
          height: 38,
          onPressed: onEdit,
        ),
      ],
    ),
  );
}

class _NoPayoutsCard extends StatelessWidget {
  const _NoPayoutsCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(20),
    borderRadius: const BorderRadius.all(Radius.circular(20)),
    child: Column(
      children: [
        Text(
          'No payout method yet',
          style: AppTypography.figtree(size: 14, weight: 800),
        ),
        const Gap(10),
        Text(
          'Add your account name and mobile number to receive your earnings.',
          textAlign: TextAlign.center,
          style: AppTypography.figtree(size: 12.5, color: AppColors.textMuted),
        ),
        const Gap(10),
        IconPillButton(
          label: 'Add account',
          icon: Icons.add_rounded,
          background: AppColors.accent,
          foreground: AppColors.surface,
          onPressed: onAdd,
        ),
      ],
    ),
  );
}

class _AddPayoutRow extends StatelessWidget {
  const _AddPayoutRow({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: PressableScale(
      scale: 0.99,
      onPressed: onPressed,
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: AppColors.divider, width: 1.5),
              ),
              child: const Icon(Icons.add_rounded, size: 16),
            ),
            const Gap(14),
            Expanded(
              child: Text(
                'Add payout method',
                style: AppTypography.figtree(size: 15, weight: 800),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: PressableScale(
      onPressed: onPressed,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.pill,
          boxShadow: AppShadows.soft,
        ),
        child: Text(
          'Log out',
          style: AppTypography.figtree(
            size: 15,
            weight: 700,
            color: AppColors.danger,
          ),
        ),
      ),
    ),
  );
}
