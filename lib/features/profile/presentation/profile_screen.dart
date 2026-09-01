import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/di/app_scope.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/theme_reveal.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/avatar_circle.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/divided_column.dart';
import '../../../shared/widgets/faith_mascot.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/pressable_scale.dart';
import 'widgets/settings_row.dart';
import '../../../app/theme/app_palette.dart';

/// Who the member is, their balance, and everything else — the identity
/// centred up top, then the settings in grouped lists.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const MemberSummary _summary = MemberSummary.placeholder;

  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) => AppScaffold(
    child: ListView(
      padding: FaithNavBar.pageInset,
      children: [
        _ProfileHeader(
          summary: _summary,
          onEdit: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
        ),
        const Gap(AppSpacing.lg),
        _RewardsCard(
          summary: _summary,
          onCashOut: () => Navigator.of(context).pushNamed(AppRoutes.rewards),
        ),
        const Gap(AppSpacing.sm),
        AppCard.flush(
          borderRadius: AppRadius.card,
          child: DividedColumn(
            children: [
              SettingsToggleRow(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                value: _notificationsEnabled,
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
              const _DarkModeRow(),
              const SettingsValueRow(
                icon: Icons.language_rounded,
                label: 'Language',
                value: 'English',
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.sm),
        AppCard.flush(
          borderRadius: AppRadius.card,
          child: DividedColumn(
            children: [
              SettingsLinkRow(
                icon: Icons.history_rounded,
                label: 'Account activity',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.accountActivity),
              ),
              SettingsLinkRow(
                icon: Icons.help_outline_rounded,
                label: 'Help center',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.helpCenter),
              ),
              SettingsLinkRow(
                icon: Icons.shield_outlined,
                label: 'Terms & privacy',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.terms),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.md),
        _LogOutButton(
          onPressed: () =>
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false),
        ),
      ],
    ),
  );
}

/// Flips the app between its two palettes, revealed from this row. The whole
/// app rebuilds on the change, so the switch reads its state straight from the
/// controller.
class _DarkModeRow extends StatelessWidget {
  const _DarkModeRow();

  @override
  Widget build(BuildContext context) => SettingsToggleRow(
    icon: Icons.dark_mode_outlined,
    label: 'Dark mode',
    value: AppScope.of(context).themeController.isDark,
    onChanged: (_) => ThemeReveal.of(context).toggle(from: context),
  );
}

/// Centred title with the edit action on the right, then the avatar, name and
/// code stacked underneath — the member is the subject of the page.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.summary, required this.onEdit});

  final MemberSummary summary;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          // Balances the button on the right so the title sits dead centre.
          const SizedBox(width: AppSpacing.iconButtonSize),
          Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: AppTypography.figtree(size: 18, weight: 800),
            ),
          ),
          CircleIconButton(
            icon: Icons.edit_outlined,
            semanticLabel: 'Edit profile',
            onPressed: onEdit,
          ),
        ],
      ),
      const Gap(AppSpacing.lg),
      AvatarCircle(name: summary.name, size: 92, bordered: true),
      const Gap(12),
      Text(
        summary.name,
        style: AppTypography.figtree(size: 22, weight: 800),
        textAlign: TextAlign.center,
      ),
      const Gap(2),
      Text(
        'Code: ${summary.referralCode}',
        style: AppTypography.figtree(
          size: 13.5,
          weight: 700,
          color: context.palette.accentText,
        ),
      ),
    ],
  );
}

/// The highlight card: the balance, and the tap that turns it into money. The
/// mascot on the right is what lifts it above the plain lists below.
class _RewardsCard extends StatelessWidget {
  const _RewardsCard({required this.summary, required this.onCashOut});

  static const double _mascotSize = 78;

  final MemberSummary summary;
  final VoidCallback onCashOut;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Cash out',
    child: PressableScale(
      scale: 0.99,
      onPressed: onCashOut,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.palette.surface,
          borderRadius: AppRadius.card,
          boxShadow: context.palette.shadowSoft,
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _AccentWash()),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  const SettingsIcon(
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Cash out',
                          style: AppTypography.figtree(size: 14.5, weight: 700),
                        ),
                        Text(
                          '${summary.pointsFormatted} pts · '
                          '${summary.pesoValue}',
                          style: AppTypography.figtree(
                            size: 12.5,
                            color: context.palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: _mascotSize,
                    height: _mascotSize,
                    child: FittedBox(child: FaithMascot()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The brand tint that fades in behind the mascot.
class _AccentWash extends StatelessWidget {
  const _AccentWash();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.45, 1],
        colors: [
          context.palette.accent.withValues(alpha: 0),
          context.palette.accent.withValues(alpha: 0.28),
        ],
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
        decoration: BoxDecoration(
          color: context.palette.surface,
          borderRadius: AppRadius.pill,
          boxShadow: context.palette.shadowSoft,
        ),
        child: Text(
          'Log out',
          style: AppTypography.figtree(
            size: 15,
            weight: 700,
            color: context.palette.danger,
          ),
        ),
      ),
    ),
  );
}
