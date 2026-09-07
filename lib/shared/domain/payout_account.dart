import 'package:flutter/foundation.dart';

/// How money leaves the app.
enum PayoutKind {
  gcash('GCash', 'gcash'),
  maya('Maya', 'maya');

  const PayoutKind(this.label, this._logo);

  final String label;
  final String _logo;

  String get logoAsset => 'assets/images/payout/$_logo.png';
}

/// A destination the member can cash out to.
class PayoutAccount {
  const PayoutAccount({
    required this.kind,
    required this.accountName,
    required this.number,
  });

  /// A Philippine mobile number: 09XX XXX XXXX.
  static const int numberLength = 11;

  final PayoutKind kind;
  final String accountName;

  /// The mobile number the wallet is registered to, digits only.
  final String number;

  String get label => kind.label;

  String get logoAsset => kind.logoAsset;

  /// The number as it is shown: the prefix and the last four, the middle
  /// hidden — enough to recognise, not enough to copy.
  String get reference => mask(number);

  /// The number a wallet is registered to has one shape; anything else is a
  /// typo the payout would bounce on.
  static String? validateNumber(String digits) {
    if (digits.isEmpty) return 'Mobile number is required.';
    if (digits.length != numberLength || !digits.startsWith('09')) {
      return 'Enter an 11-digit mobile number starting with 09.';
    }
    return null;
  }

  static String mask(String number) {
    if (number.length < 8) return number;
    return '${number.substring(0, 4)} •••• '
        '${number.substring(number.length - 4)}';
  }

  static const List<PayoutAccount> placeholder = [
    PayoutAccount(
      kind: PayoutKind.gcash,
      accountName: 'Ivy Santos',
      number: '09171231234',
    ),
    PayoutAccount(
      kind: PayoutKind.maya,
      accountName: 'Ivy Santos',
      number: '09171231234',
    ),
  ];
}

/// The member's payout accounts, observable: one per wallet at most.
///
/// Every place that lists or edits them draws from here, so an account saved
/// on the edit screen is what the cash-out picker offers in the same frame.
/// Kept for the session until the API can hold it, and it leaves with the
/// session.
class PayoutAccounts extends ChangeNotifier {
  PayoutAccounts({Iterable<PayoutAccount> initial = const []}) {
    for (final account in initial) {
      _byKind[account.kind] = account;
    }
  }

  final Map<PayoutKind, PayoutAccount> _byKind = {};

  /// In the order the wallets are listed.
  List<PayoutAccount> get all => [
    for (final kind in PayoutKind.values) ?_byKind[kind],
  ];

  bool get isEmpty => _byKind.isEmpty;

  /// The wallets not set up yet — what an "add" affordance offers.
  List<PayoutKind> get missingKinds => [
    for (final kind in PayoutKind.values)
      if (!_byKind.containsKey(kind)) kind,
  ];

  PayoutAccount? forKind(PayoutKind kind) => _byKind[kind];

  /// Adds the account, or replaces the one already kept for its wallet.
  void save(PayoutAccount account) {
    _byKind[account.kind] = account;
    notifyListeners();
  }

  void clear() {
    if (_byKind.isEmpty) return;
    _byKind.clear();
    notifyListeners();
  }
}
