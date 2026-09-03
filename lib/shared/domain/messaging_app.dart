/// Chat and social apps a share can be handed to, in the order the sheets
/// show them.
enum MessagingApp {
  messenger('Messenger', 'messenger', 'com.facebook.orca'),
  facebook('Facebook', 'facebook', 'com.facebook.katana'),
  whatsapp('WhatsApp', 'whatsapp', 'com.whatsapp'),
  viber('Viber', 'viber', 'com.viber.voip');

  const MessagingApp(this.label, this._logo, this.androidPackage);

  final String label;
  final String _logo;

  /// What Android's share intent is aimed at.
  final String androidPackage;

  String get logoAsset => 'assets/images/share/$_logo.png';
}
