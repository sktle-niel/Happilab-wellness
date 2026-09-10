import 'package:flutter/material.dart';

import '../../../app/di/app_scope.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/catalogue.dart';
import '../../../shared/domain/delivery_address.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/card_skeleton.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/remote_image.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/section_header.dart';
import 'checkout_controller.dart';

/// Getting a product: how many, where it goes, and the one button that
/// places the order. Without a delivery address the button waits and the
/// address card asks for one first.
class GetProductScreen extends StatefulWidget {
  const GetProductScreen({required this.product, super.key});

  final Product product;

  /// The product the route was opened for; the first of the showcase when
  /// none was handed over, so a bad deep link still lands on a real page.
  static Product productFrom(Object? arguments) =>
      arguments is Product ? arguments : Product.showcase.first;

  @override
  State<GetProductScreen> createState() => _GetProductScreenState();
}

class _GetProductScreenState extends State<GetProductScreen> {
  CheckoutController? _checkout;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _checkout ??= CheckoutController(
      product: widget.product,
      addresses: scope.deliveryAddress,
      orders: scope.repositories.orders,
    )..loadAddress();
  }

  @override
  void dispose() {
    _checkout?.dispose();
    super.dispose();
  }

  Future<void> _setAddress() =>
      Navigator.of(context).pushNamed(AppRoutes.deliveryAddress);

  Future<void> _place() async {
    final navigator = Navigator.of(context);
    final overlay = Overlay.of(context);
    final outcome = await _checkout!.place();
    if (outcome == null || !mounted) return;
    outcome.fold((receipt) {
      AppToast.success(
        context,
        'Order ${receipt.reference} placed',
        detail: 'We will confirm it soon.',
      );
      navigator.pop();
    }, (error) => AppToast.failureOn(overlay, error));
  }

  @override
  Widget build(BuildContext context) {
    final checkout = _checkout!;

    return AppScaffold(
      child: ListView(
        padding: AppSpacing.pageInset,
        children: [
          const ScreenHeader(title: 'Checkout'),
          const Gap(AppSpacing.md),
          ListenableBuilder(
            listenable: checkout,
            builder: (context, _) => _CheckoutBody(
              checkout: checkout,
              onSetAddress: _setAddress,
              onPlace: _place,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBody extends StatelessWidget {
  const _CheckoutBody({
    required this.checkout,
    required this.onSetAddress,
    required this.onPlace,
  });

  final CheckoutController checkout;
  final VoidCallback onSetAddress;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _ProductCard(checkout: checkout),
      const Gap(AppSpacing.md),
      const SectionHeader(title: 'Deliver to'),
      const Gap(AppSpacing.sm),
      _AddressCard(checkout: checkout, onSetAddress: onSetAddress),
      const Gap(AppSpacing.lg),
      AppButton(
        label: 'Place order',
        onPressed: checkout.canPlace ? onPlace : null,
        isLoading: checkout.isPlacing,
      ),
    ],
  );
}

/// The product with its price line and the quantity under it.
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.checkout});

  static const double _photo = 76;

  final CheckoutController checkout;

  @override
  Widget build(BuildContext context) {
    final product = checkout.product;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              RemoteImage(
                url: product.imageUrl,
                width: _photo,
                height: _photo,
                borderRadius: AppRadius.input,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTypography.figtree(size: 16, weight: 800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      checkout.priceLine,
                      style: AppTypography.figtree(size: 15, weight: 800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          _QuantityRow(checkout: checkout),
        ],
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({required this.checkout});

  final CheckoutController checkout;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          'Quantity',
          style: AppTypography.figtree(
            size: 13,
            weight: 700,
            color: context.palette.textMuted,
          ),
        ),
      ),
      CircleIconButton(
        icon: Icons.remove_rounded,
        semanticLabel: 'One less',
        onPressed: checkout.canRemoveOne ? checkout.removeOne : null,
      ),
      SizedBox(
        width: 40,
        child: Text(
          '${checkout.quantity}',
          textAlign: TextAlign.center,
          style: AppTypography.figtree(size: 17, weight: 800),
        ),
      ),
      CircleIconButton(
        icon: Icons.add_rounded,
        semanticLabel: 'One more',
        onPressed: checkout.canAddOne ? checkout.addOne : null,
      ),
    ],
  );
}

/// Where the order goes: the saved address with a way to change it, the
/// wait while it is read, the failure with a retry, or the ask for one.
class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.checkout, required this.onSetAddress});

  final CheckoutController checkout;
  final VoidCallback onSetAddress;

  @override
  Widget build(BuildContext context) {
    final address = checkout.address;
    if (address != null) {
      return _SavedAddress(address: address, onChange: onSetAddress);
    }
    final error = checkout.addressError;
    if (error != null) {
      return ErrorView(error: error, onRetry: checkout.loadAddress);
    }
    if (!checkout.isAddressLoaded) return const CardSkeleton(lines: 3);
    return _NoAddress(onSetAddress: onSetAddress);
  }
}

class _SavedAddress extends StatelessWidget {
  const _SavedAddress({required this.address, required this.onChange});

  final DeliveryAddress address;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${address.fullName} · ${address.mobileSpaced}',
                style: AppTypography.figtree(size: 14, weight: 800),
              ),
              const Gap(4),
              Text(
                address.oneLine,
                style: AppTypography.figtree(
                  size: 13,
                  height: 1.35,
                  color: context.palette.textMuted,
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        TextButton(onPressed: onChange, child: const Text('Change')),
      ],
    ),
  );
}

class _NoAddress extends StatelessWidget {
  const _NoAddress({required this.onSetAddress});

  final VoidCallback onSetAddress;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No delivery address yet',
          style: AppTypography.figtree(size: 14, weight: 800),
        ),
        const Gap(4),
        Text(
          'Tell us where to send your order before you place it.',
          style: AppTypography.figtree(
            size: 13,
            color: context.palette.textMuted,
          ),
        ),
        const Gap(12),
        AppButton.secondary(
          label: 'Add delivery address',
          onPressed: onSetAddress,
        ),
      ],
    ),
  );
}
