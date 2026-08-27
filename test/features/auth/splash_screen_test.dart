import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/app/theme/app_tokens.dart';
import 'package:happilab/shared/widgets/faith_wordmark.dart';

import '../../support/harness.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('shows the brand lockup while it holds', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(testApp(initialRoute: AppRoutes.splash));
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text('FAITH'), findsOneWidget);
      expect(find.text('WELLNESS'), findsOneWidget);
      expect(find.text(FaithWordmark.tagline), findsOneWidget);
    });

    testWidgets('hands over to sign in and cannot be navigated back to', (
      tester,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(testApp(initialRoute: AppRoutes.splash));

      await tester.pump(AppDuration.splash);
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('FAITH'), findsNothing);
    });
  });
}
