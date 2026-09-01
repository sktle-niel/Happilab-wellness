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
      expect(build(points: 400).amountOptions, [400]);
    });

    test('does not offer the balance twice when it is already a preset', () {
      expect(build(points: 1000).amountOptions, [500, 1000]);
    });

    test('offers nothing to a member with no points', () {
      expect(build(points: 0).amountOptions, isEmpty);
    });

    test('needs both an amount and a destination before it will send', () {
      final controller = build()..selectAmount(500);
      expect(controller.canSubmit, isFalse);

      controller.selectDestination(gcash);
      expect(controller.canSubmit, isTrue);
    });

    test('will not send a balance below the minimum', () {
      expect(400, lessThan(CashOutTerms.minimumPoints));

      final controller = build(points: 400)
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
