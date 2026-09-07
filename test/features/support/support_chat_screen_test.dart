import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/features/support/domain/support_chat.dart';
import 'package:happilab/features/support/presentation/widgets/chat_bubble.dart';
import 'package:happilab/features/support/presentation/widgets/support_avatar.dart';
import 'package:happilab/shared/widgets/member_avatar.dart';

import '../../support/harness.dart';

void main() {
  /// Support answers after a beat of up to three seconds; long enough to be
  /// sure it has.
  const reply = Duration(milliseconds: 3500);

  Future<void> pumpChat(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.supportChat));
    await tester.pump();
  }

  group('SupportChatScreen', () {
    testWidgets('opens from the help center', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(testApp(initialRoute: AppRoutes.helpCenter));
      await tester.pump();

      await tapVisible(tester, find.text('Chat with support'));
      await tester.pumpAndSettle();

      expect(find.text(SupportChatCopy.agentName), findsOneWidget);
      expect(find.text(SupportChatCopy.greeting), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      // The header and the greeting both wear the app's face.
      expect(find.byType(SupportAvatar), findsNWidgets(2));
      expect(find.byType(MemberAvatar), findsNothing);
    });

    testWidgets('a topic chip opens the conversation and gets an answer', (
      tester,
    ) async {
      await pumpChat(tester);

      // The chip row scrolls sideways; the topic sits past the first screen.
      await tester.dragUntilVisible(
        find.text('Cash out issue'),
        find.byType(ListView).last,
        const Offset(-160, 0),
      );
      await tester.pump();
      await tester.tap(find.text('Cash out issue'));
      await tester.pump();
      expect(find.text(SupportTopic.cashOut.opener), findsOneWidget);
      // Seen typing: the dots in the thread, and the word in the header.
      expect(find.byType(TypingBubble), findsOneWidget);
      expect(find.text(SupportChatCopy.typing), findsOneWidget);

      await tester.pump(reply);
      expect(find.text(SupportTopic.cashOut.followUp), findsOneWidget);
      expect(find.byType(TypingBubble), findsNothing);
      expect(find.text(SupportChatCopy.status), findsOneWidget);
    });

    testWidgets('the agent command brings a person into the chat', (
      tester,
    ) async {
      await pumpChat(tester);

      await tester.enterText(find.byType(TextField), '/agent');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();

      expect(find.text(SupportChatCopy.requestingAgent), findsOneWidget);
      expect(find.text(SupportChatCopy.talkToAgent), findsNothing);

      // The longest line the simulated desk deals, plus the greeting.
      await tester.pump(const Duration(seconds: 20));

      expect(find.textContaining('has joined the chat.'), findsOneWidget);
      expect(find.text(SupportChatCopy.agentStatus), findsOneWidget);
      expect(find.text(SupportChatCopy.endChat), findsOneWidget);

      await tester.tap(find.text(SupportChatCopy.endChat));
      await tester.pump();

      expect(find.textContaining('has ended.'), findsOneWidget);
      expect(find.text(SupportChatCopy.talkToAgent), findsOneWidget);
    });

    testWidgets('a typed message is sent and acknowledged', (tester) async {
      await pumpChat(tester);

      await tester.enterText(find.byType(TextField), 'Hello there');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();

      expect(find.text('Hello there'), findsOneWidget);
      expect(find.byType(MemberAvatar), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );

      await tester.pump(reply);
      expect(find.text(SupportChatCopy.acknowledgement), findsOneWidget);
    });
  });
}
