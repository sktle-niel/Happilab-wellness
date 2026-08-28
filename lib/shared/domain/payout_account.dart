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
    required this.reference,
  });

  final PayoutKind kind;
  final String accountName;

  /// Mobile number, already masked for display.
  final String reference;

  String get label => kind.label;

  String get logoAsset => kind.logoAsset;

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
