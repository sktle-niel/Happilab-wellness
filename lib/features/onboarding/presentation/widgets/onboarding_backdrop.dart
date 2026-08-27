import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/brand_mark.dart';
import '../../../../shared/widgets/faith_wordmark.dart';
import '../../../../shared/widgets/floating_petals.dart';
import '../../../../shared/widgets/remote_image.dart';

/// What the onboarding pitch sits on top of.
///
/// The design cycles a brand cover and two clips of stock footage; the app
/// carries the cover and the still until there is real brand footage to play,
/// so [count] is derived rather than hardcoded and the pips stay honest.
class OnboardingBackdrop extends StatelessWidget {
  const OnboardingBackdrop({required this.stageIndex, super.key});

  /// Stock photography from the design canvas — replace with brand imagery.
  static const String _posterUrl =
      'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=900&q=80';

  /// How many stages the backdrop cycles through.
  static const int count = 2;

  final int stageIndex;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: AppColors.canvas),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: stageIndex == 0
            ? const _BrandCover(key: ValueKey('cover'))
            : const RemoteImage(
                key: ValueKey('poster'),
                url: _posterUrl,
                fit: BoxFit.cover,
              ),
      ),
      const _ReadabilityScrim(),
    ],
  );
}

/// The cream cover: petals, mark and wordmark, held high so the copy below has
/// room.
class _BrandCover extends StatelessWidget {
  const _BrandCover({super.key});

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.canvas,
    child: Stack(
      children: [
        Positioned.fill(child: FloatingPetals()),
        Align(
          alignment: Alignment(0, -0.55),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark(size: 150),
              SizedBox(height: 5),
              FaithWordmark(showTagline: false, scale: 0.87),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Darkens the lower half so white copy stays legible over any photograph.
class _ReadabilityScrim extends StatelessWidget {
  const _ReadabilityScrim();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x0D1E1408), Color(0xD11E1408), Color(0xEB1E1408)],
        stops: [0.3, 0.78, 1],
      ),
    ),
    child: SizedBox.expand(),
  );
}
