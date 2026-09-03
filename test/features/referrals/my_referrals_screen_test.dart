import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/shared/utils/share_actions.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpReferrals(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.myReferrals));
    await tester.pump();
  }

  group('MyReferralsScreen', () {
    testWidgets('share opens the invite sheet with every way out', (
      tester,
    ) async {
      await pumpReferrals(tester);

      await tester.tap(find.text('Share'));
      await settleSheet(tester);

      expect(find.text('Invite a friend'), findsOneWidget);
      for (final app in [
        'Messenger',
        'TikTok',
        'Facebook',
        'WhatsApp',
        'Viber',
      ]) {
        expect(find.text(app), findsOneWidget, reason: app);
      }
      expect(find.text('Copy link'), findsOneWidget);
    });

    testWidgets('facebook asks whether the share is a post or a story', (
      tester,
    ) async {
      await pumpReferrals(tester);
      await tester.tap(find.text('Share'));
      await settleSheet(tester);

      await tester.tap(find.text('Facebook'));
      await settleSheet(tester);

      expect(find.text('Share to Facebook'), findsOneWidget);
      expect(find.text('Post'), findsOneWidget);
      expect(find.text('Story'), findsOneWidget);
    });

    testWidgets('cancel closes the sheet', (tester) async {
      await pumpReferrals(tester);
      await tester.tap(find.text('Share'));
      await settleSheet(tester);

      await tester.tap(find.text('Cancel'));
      await settleSheet(tester);

      expect(find.text('Invite a friend'), findsNothing);
    });
  });

  group('ShareActions invite', () {
    test('the invite link carries the code', () {
      final link = ShareActions.inviteLink('FCV-IVY24');

      expect(link.isScheme('https'), isTrue);
      expect(link.queryParameters['ref'], 'FCV-IVY24');
    });

    test('the invite message carries the code and the link', () {
      final message = ShareActions.inviteMessage('FCV-IVY24');

      expect(message, contains('FCV-IVY24'));
      expect(message, contains('${ShareActions.inviteLink('FCV-IVY24')}'));
    });

    test('the Messenger deep link wraps the invite link whole', () {
      final link = ShareActions.inviteLink('FCV-IVY24');
      final messenger = ShareActions.messengerShare(link);

      expect(messenger.isScheme('fb-messenger'), isTrue);
      expect(messenger.queryParameters['link'], '$link');
    });

    test('the Facebook dialog posts the invite link', () {
      final link = ShareActions.inviteLink('FCV-IVY24');
      final facebook = ShareActions.facebookShare(link);

      expect(facebook.host, 'www.facebook.com');
      expect(facebook.queryParameters['u'], '$link');
    });

    test('WhatsApp and Viber carry the whole message', () {
      const code = 'FCV-IVY24';
      final message = ShareActions.inviteMessage(code);

      expect(
        ShareActions.whatsappShare(message).queryParameters['text'],
        message,
      );
      expect(ShareActions.viberShare(message).queryParameters['text'], message);
    });
  });
}
