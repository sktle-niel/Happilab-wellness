/// How money leaves the app.
enum PayoutKind {
  gcash('GCash'),
  maya('Maya'),
  bank('Bank transfer');

  const PayoutKind(this.label);

  final String label;
}

/// A destination the member can cash out to.
class PayoutAccount {
  const PayoutAccount({
    required this.kind,
    required this.accountName,
    required this.reference,
  });

  final PayoutKind kind;
  final String accountName;

  /// Mobile number or account number, already masked for display.
  final String reference;

  String get label => kind.label;

  static const List<PayoutAccount> placeholder = [
    PayoutAccount(
      kind: PayoutKind.gcash,
      accountName: 'Ivy Santos',
      reference: '0917 •••• 1234',
    ),
    PayoutAccount(
      kind: PayoutKind.maya,
      accountName: 'Ivy Santos',
      reference: '0917 •••• 1234',
    ),
  ];
}

/// Banks offered as a third payout destination.
///
/// A plain list for now; a real integration would fetch what the payment
/// provider actually supports rather than hardcoding it.
abstract final class PhilippineBanks {
  static const List<String> all = [
    'BDO Unibank',
    'BPI',
    'Metrobank',
    'Landbank',
    'Security Bank',
    'UnionBank',
    'PNB',
    'RCBC',
  ];
}
