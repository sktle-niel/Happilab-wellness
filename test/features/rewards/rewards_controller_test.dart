import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/features/rewards/domain/cash_out.dart';
import 'package:happilab/features/rewards/presentation/rewards_controller.dart';
import 'package:happilab/shared/domain/payout_account.dart';

void main() {
  group('RewardsController', () {
    const gcash = PayoutAccount(
      kind: PayoutKind.gcash,
      accountName: 'Ivy Santos',
      reference: '0917 •••• 1234',
    );

    RewardsController build({int points = 1240}) {
      final controller = RewardsController(availablePoints: points);
      addTearDown(controller.dispose);
      return controller;
    }

    test('offers the presets the member can afford, plus their balance', () {
      expect(build().amountOptions, [500, 1000, 1240]);
      expect(build(points: 700).amountOptions, [500, 700]);
    });

    test('does not offer the balance twice when it is already a preset', () {
      expect(build(points: 1000).amountOptions, [500, 1000]);
    });

    test('offers nothing until the balance reaches the minimum', () {
      const minimum = CashOutTerms.minimumPoints;

      expect(build(points: 0).amountOptions, isEmpty);
      expect(build(points: minimum - 1).amountOptions, isEmpty);
      expect(build(points: minimum).amountOptions, [minimum]);
    });

    test('offers only amounts the form will actually send', () {
      // A chip the member can tap that leaves the button disabled, with
      // nothing on screen to explain it, is the gap this closes.
      for (final points in [0, 400, 500, 700, 1240, 5000]) {
        final controller = build(points: points)..selectDestination(gcash);

        for (final amount in controller.amountOptions) {
          controller.selectAmount(amount);
          expect(
            controller.canSubmit,
            isTrue,
            reason: '$amount offered on a balance of $points',
          );
        }
      }
    });

    test('needs both an amount and a destination before it will send', () {
      final controller = build()..selectAmount(500);
      expect(controller.canSubmit, isFalse);

      controller.selectDestination(gcash);
      expect(controller.canSubmit, isTrue);
    });

    test('refuses an amount below the minimum, however it was chosen', () {
      expect(400, lessThan(CashOutTerms.minimumPoints));

      final controller = build()
        ..selectAmount(400)
        ..selectDestination(gcash);

      expect(controller.canSubmit, isFalse);
    });

    test('will not send more than the member has', () {
      final controller = build(points: 600)
        ..selectAmount(1000)
        ..selectDestination(gcash);

      expect(controller.canSubmit, isFalse);
    });

    test('submit does nothing until the form allows it', () {
      final controller = build()..submit();
      expect(controller.isSubmitted, isFalse);

      controller
        ..selectAmount(500)
        ..selectDestination(gcash)
        ..submit();
      expect(controller.isSubmitted, isTrue);
    });

    test('reads the request back to the member', () {
      final controller = build()
        ..selectAmount(500)
        ..selectDestination(gcash);

      expect(
        controller.confirmation,
        'We are sending ₱500 to your GCash account 0917 •••• 1234.',
      );
    });

    test('has nothing to read back before a choice is made', () {
      expect(build().confirmation, isEmpty);
    });

    test('reset returns an empty form, ready for another request', () {
      final controller = build()
        ..selectAmount(500)
        ..selectDestination(gcash)
        ..submit()
        ..reset();

      expect(controller.isSubmitted, isFalse);
      expect(controller.amount, isNull);
      expect(controller.destination, isNull);
      expect(controller.canSubmit, isFalse);
    });
  });
}
