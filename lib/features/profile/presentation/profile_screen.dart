import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/shell/widgets/faith_nav_bar.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/member_summary.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/avatar_circle.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/divided_column.dart';
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
        _PreferencesGroup(
          notificationsEnabled: _notificationsEnabled,
          onNotificationsChanged: (value) =>
              setState(() => _notificationsEnabled = value),
        ),
        const Gap(AppSpacing.sm),
        const _SupportGroup(),
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

/// What the member can switch on and off.
class _PreferencesGroup extends StatelessWidget {
  const _PreferencesGroup({
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
  });

  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) => AppCard.flush(
    borderRadius: AppRadius.card,
    child: DividedColumn(
      children: [
        SettingsToggleRow(
          icon: Icons.notifications_none_rounded,
          label: 'Notifications',
          value: notificationsEnabled,
          onChanged: onNotificationsChanged,
        ),
        const SettingsValueRow(
          icon: Icons.language_rounded,
          label: 'Language',
          value: 'English',
        ),
      ],
    ),
  );
}

/// Where the member goes for their history, for help, and for the agreement.
class _SupportGroup extends StatelessWidget {
  const _SupportGroup();

  @override
  Widget build(BuildContext context) => AppCard.flush(
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
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.terms),
        ),
      ],
    ),
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
/// falcon banner behind it is what lifts it above the plain lists below.
class _RewardsCard extends StatelessWidget {
  const _RewardsCard({required this.summary, required this.onCashOut});

  /// Short enough that the banner, held at its own proportions, leaves the
  /// left third of the card to the wording.
  static const double _height = 96;

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
        height: _height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.palette.surface,
          borderRadius: AppRadius.card,
          boxShadow: context.palette.shadowSoft,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _CashOutBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _CashOutLabel(summary: summary),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The falcon artwork, hung off the right edge at its own proportions rather
/// than stretched to the card.
///
/// The picture was painted on black. That black is keyed out of the asset and
/// the glow left translucent, so what stands behind the bird is whatever the
/// card is — white in the light theme, charcoal in the dark one — instead of a
/// slab that belongs to neither.
class _CashOutBanner extends StatelessWidget {
  const _CashOutBanner();

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/cash-out-card.png',
    fit: BoxFit.fitHeight,
    alignment: Alignment.centerRight,
    filterQuality: FilterQuality.medium,
    semanticLabel: 'A falcon looking on',
  );
}

/// The wording on the rewards card: what the action is, and what it is worth.
class _CashOutLabel extends StatelessWidget {
  const _CashOutLabel({required this.summary});

  final MemberSummary summary;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('Cash out', style: AppTypography.figtree(size: 15, weight: 800)),
      Text(
        '${summary.pointsFormatted} pts · ${summary.pesoValue}',
        style: AppTypography.figtree(
          size: 12.5,
          color: context.palette.textMuted,
        ),
      ),
    ],
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
