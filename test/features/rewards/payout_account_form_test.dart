import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/features/rewards/presentation/payout_account_form.dart';
import 'package:happilab/shared/domain/payout_account.dart';

void main() {
  group('PayoutAccountForm', () {
    const saved = PayoutAccount(
      kind: PayoutKind.maya,
      accountName: 'Ivy Santos',
      number: '09171231234',
    );

    PayoutAccountForm build({PayoutAccount? existing}) {
      final form = PayoutAccountForm(kind: PayoutKind.maya, existing: existing);
      addTearDown(form.dispose);
      return form;
    }

    test('opens empty for a wallet with nothing saved', () {
      final form = build();

      expect(form.isNew, isTrue);
      expect(form.accountName.text, isEmpty);
      expect(form.number.text, isEmpty);
    });

    test('opens on what is saved', () {
      final form = build(existing: saved);

      expect(form.isNew, isFalse);
      expect(form.accountName.text, 'Ivy Santos');
      expect(form.number.text, '09171231234');
    });

    test('refuses an empty form field by field', () {
      final form = build();

      expect(form.submit(), isNull);
      expect(form.accountNameError, 'Account name is required.');
      expect(form.numberError, 'Mobile number is required.');
    });

    test('keeps only the digits of the number', () {
      final form = build()
        ..accountName.text = 'Ivy Santos'
        ..number.text = '0917 123-1234';

      final account = form.submit();

      expect(account?.number, '09171231234');
      expect(account?.reference, '0917 •••• 1234');
      expect(account?.kind, PayoutKind.maya);
    });

    test('refuses a number of the wrong shape', () {
      final form = build()
        ..accountName.text = 'Ivy Santos'
        ..number.text = '0917123';

      expect(form.submit(), isNull);
      expect(
        form.numberError,
        'Enter an 11-digit mobile number starting with 09.',
      );
    });

    test('clears an error once the member starts fixing it', () {
      final form = build()..submit();
      var notified = 0;
      form.addListener(() => notified++);

      form.onNumberChanged('0');

      expect(form.numberError, isNull);
      expect(notified, 1);
    });
  });
}
