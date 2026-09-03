import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/app_typography.dart';
import '../domain/catalogue.dart';
import '../utils/share_actions.dart';
import 'app_card.dart';
import 'gap.dart';
import 'pressable_scale.dart';
import '../../app/theme/app_palette.dart';

/// Where to send a product: copy the message, or open its listing on a
/// storefront with the member's code attached.
///
/// Every choice closes the sheet first and then acts through the caller's
/// context, so a snackbar has a live scaffold to land on.
class ProductShareSheet extends StatelessWidget {
  const ProductShareSheet({
    required this.product,
    required this.onCopy,
    required this.onOpen,
    super.key,
  });

  static const String _note =
      'Your code is attached automatically — you earn on every sale';

  final Product product;
  final VoidCallback onCopy;
  final ValueChanged<SharePlatform> onOpen;

  static Future<void> show(
    BuildContext context, {
    required Product product,
    required String referralCode,
  }) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (_) => ProductShareSheet(
      product: product,
      onCopy: () => ShareActions.copy(
        context,
        ShareActions.productMessage(product, referralCode),
        confirmation: 'Message for ${product.name} copied.',
      ),
      onOpen: (platform) => ShareActions.open(
        context,
        product.shareLink(platform, referralCode),
        destination: platform.label,
      ),
    ),
  );

  void _choose(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        shadow: context.palette.shadowCard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Handle(),
            const Gap(14),
            Text(
              'Share ${product.name}',
              textAlign: TextAlign.center,
              style: AppTypography.figtree(size: 17, weight: 800),
            ),
            const Gap(4),
            Text(
              _note,
              textAlign: TextAlign.center,
              style: AppTypography.figtree(
                size: 12.5,
                color: context.palette.textMuted,
              ),
            ),
            const Gap(20),
            _ShareOptions(
              onCopy: () => _choose(context, onCopy),
              onOpen: (platform) => _choose(context, () => onOpen(platform)),
            ),
            const Gap(20),
            _CancelButton(onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    ),
  );
}

/// Where a share can go: the link itself, then every storefront.
class _ShareOptions extends StatelessWidget {
  const _ShareOptions({required this.onCopy, required this.onOpen});

  final VoidCallback onCopy;
  final ValueChanged<SharePlatform> onOpen;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _ShareOption(
        label: 'Copy link',
        onPressed: onCopy,
        child: Icon(
          Icons.link_rounded,
          size: 24,
          color: context.palette.accentText,
        ),
      ),
      for (final platform in SharePlatform.values)
        _ShareOption(
          label: platform.label,
          onPressed: () => onOpen(platform),
          // The store's app icon fills the disc, as it does on a phone's
          // home screen.
          child: Image.asset(
            platform.logoAsset,
            fit: BoxFit.cover,
            cacheWidth: 174,
          ),
        ),
    ],
  );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: context.palette.divider,
      borderRadius: AppRadius.pill,
    ),
  );
}

/// A round target with its name beneath — a logo or an icon, same footprint.
class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.label,
    required this.onPressed,
    required this.child,
  });

  static const double _size = 58;

  final String label;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: PressableScale(
      scale: 0.92,
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _size,
            height: _size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.palette.tint,
              shape: BoxShape.circle,
            ),
            // Drawn over the child so a full-bleed icon still gets the ring.
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.palette.divider),
            ),
            child: child,
          ),
          const Gap(8),
          Text(label, style: AppTypography.figtree(size: 12, weight: 700)),
        ],
      ),
    ),
  );
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: PressableScale(
      onPressed: onPressed,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.palette.tint,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          'Cancel',
          style: AppTypography.figtree(
            size: 15,
            weight: 700,
            color: context.palette.accentText,
          ),
        ),
      ),
    ),
  );
}
