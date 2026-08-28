import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/domain/catalogue.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/rise_in.dart';
import 'widgets/product_card.dart';
import '../../../app/theme/app_palette.dart';

/// The product showcase that plays between the loader and the onboarding pitch.
///
/// The cards deal themselves in one after another, then the screen hands over
/// on its own — it is an interstitial, not a destination, so it carries no
/// controls of its own.
class ProductIntroScreen extends StatefulWidget {
  const ProductIntroScreen({super.key});

  /// How long the showcase holds once the last card has landed.
  static const Duration hold = Duration(milliseconds: 3200);

  @override
  State<ProductIntroScreen> createState() => _ProductIntroScreenState();
}

class _ProductIntroScreenState extends State<ProductIntroScreen>
    with SingleTickerProviderStateMixin {
  /// Resting tilt per card, in degrees — taken from the design canvas.
  static const List<double> _tilts = [-4, 3, -2.5, 2];

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  Timer? _handoff;

  @override
  void initState() {
    super.initState();
    _handoff = Timer(ProductIntroScreen.hold, _continueToOnboarding);
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  void _continueToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.palette.canvas,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _ShowcaseHeading(),
                const Gap(AppSpacing.md),
                for (final (index, product) in Product.showcase.indexed) ...[
                  if (index > 0) const Gap(12),
                  RiseIn(
                    animation: _entrance,
                    // Each card starts a beat after the one above it.
                    begin: index * 0.18,
                    end: 0.55 + index * 0.15,
                    offset: 120 + index * 20,
                    child: ProductCard(
                      product: product,
                      tiltDegrees: _tilts[index % _tilts.length],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ShowcaseHeading extends StatelessWidget {
  const _ShowcaseHeading();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'FALCON CREST VENTURES',
        style: AppTypography.figtree(
          size: 11,
          weight: 800,
          letterSpacing: 2.64,
          color: context.palette.accentText,
        ),
      ),
      Text(
        'Our Products',
        style: AppTypography.figtree(
          size: 22,
          weight: 800,
          letterSpacing: -0.22,
        ),
      ),
    ],
  );
}
