import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/features/rewards/data/fake_rewards_repository.dart';
import 'package:happilab/features/rewards/domain/cash_out.dart';
import 'package:happilab/features/rewards/presentation/rewards_controller.dart';
import 'package:happilab/shared/data/fake_payout_accounts_repository.dart';
import 'package:happilab/shared/domain/payout_account.dart';

void main() {
  group('RewardsController', () {
    const gcash = PayoutAccount(
      kind: PayoutKind.gcash,
      accountName: 'Ivy Santos',
      number: '09171231234',
    );

    late PayoutAccounts wallets;

    RewardsController build({int points = 1240}) {
      wallets = PayoutAccounts(
        FakePayoutAccountsRepository(initial: PayoutAccount.placeholder),
      );
      addTearDown(wallets.dispose);
      final controller = RewardsController(
        availablePoints: points,
        wallets: wallets,
        rewards: const FakeRewardsRepository(),
      );
      addTearDown(controller.dispose);
      return controller;
    }

    test('follows an edit to the chosen wallet', () async {
      final controller = build()..selectDestination(gcash);
      await wallets.load();
      const edited = PayoutAccount(
        kind: PayoutKind.gcash,
        accountName: 'Ivy S. Santos',
        number: '09170000000',
      );

      wallets.save(edited);

      expect(controller.destination, edited);
      expect(controller.accounts, contains(edited));
      expect(controller.missingKinds, isEmpty);
    });

    test('offers the presets the member can afford, plus their balance', () {
      expect(build().amountOptions, [1000, 1240]);
      expect(build(points: 2300).amountOptions, [1000, 2000, 2300]);
    });

    test('does not offer the balance twice when it is already a preset', () {
      expect(build(points: 2000).amountOptions, [1000, 2000]);
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

    test('takes a typed amount within the rules', () {
      final controller = build()..selectDestination(gcash);

      controller.onCustomAmountChanged('1,200');
      expect(controller.amount, 1200);
      expect(controller.customAmountError, isNull);
      expect(controller.canSubmit, isTrue);

      controller.onCustomAmountChanged('900');
      expect(controller.amount, isNull);
      expect(controller.customAmountError, 'Minimum cash out is 1,000 pts.');
      expect(controller.canSubmit, isFalse);

      controller.onCustomAmountChanged('5000');
      expect(controller.customAmountError, 'You only have 1,240 pts.');
      expect(controller.canSubmit, isFalse);

      controller.onCustomAmountChanged('');
      expect(controller.amount, isNull);
      expect(controller.customAmountError, isNull);
    });

    test('a preset stands in for whatever was typed', () {
      final controller = build()
        ..customAmount.text = '900'
        ..onCustomAmountChanged('900');

      controller.selectAmount(1000);

      expect(controller.amount, 1000);
      expect(controller.customAmount.text, isEmpty);
      expect(controller.customAmountError, isNull);
    });

    test('nothing can be cashed out below the minimum balance', () {
      expect(build(points: 999).canCashOut, isFalse);
      expect(build(points: 1000).canCashOut, isTrue);
    });

    test('needs both an amount and a destination before it will send', () {
      final controller = build()..selectAmount(1000);
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

    test('submit does nothing until the form allows it', () async {
      final controller = build();
      await controller.submit();
      expect(controller.isSubmitted, isFalse);

      controller
        ..selectAmount(1000)
        ..selectDestination(gcash);
      await controller.submit();
      expect(controller.isSubmitted, isTrue);
    });

    test('reads the request back to the member', () {
      final controller = build()
        ..selectAmount(1000)
        ..selectDestination(gcash);

      expect(
        controller.confirmation,
        'We are sending ₱1,000 to your GCash account 0917 •••• 1234.',
      );
    });

    test('has nothing to read back before a choice is made', () {
      expect(build().confirmation, isEmpty);
    });

    test('reset returns an empty form, ready for another request', () async {
      final controller = build()
        ..selectAmount(1000)
        ..selectDestination(gcash);
      await controller.submit();
      controller.reset();

      expect(controller.isSubmitted, isFalse);
      expect(controller.amount, isNull);
      expect(controller.destination, isNull);
      expect(controller.canSubmit, isFalse);
    });
  });
}
