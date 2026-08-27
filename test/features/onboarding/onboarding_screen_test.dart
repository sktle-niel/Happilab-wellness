import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/shared/domain/program_terms.dart';
import 'package:happilab/features/onboarding/presentation/onboarding_screen.dart';
import 'package:happilab/features/onboarding/presentation/widgets/onboarding_backdrop.dart';
import 'package:happilab/features/onboarding/presentation/widgets/stage_dots.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpOnboarding(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.onboarding));
    await tester.pump(const Duration(milliseconds: 700));
  }

  group('OnboardingScreen', () {
    testWidgets('states the offer with the programme rates', (tester) async {
      await pumpOnboarding(tester);

      expect(find.text(OnboardingScreen.headline), findsOneWidget);
      expect(
        find.textContaining(ProgramTerms.earnRate),
        findsOneWidget,
        reason: 'the earn rate is the whole pitch',
      );
      expect(
        find.textContaining(ProgramTerms.pointsConversion),
        findsOneWidget,
      );
    });

    testWidgets('shows one pip per backdrop stage', (tester) async {
      await pumpOnboarding(tester);

      final dots = tester.widget<StageDots>(find.byType(StageDots));
      expect(dots.count, OnboardingBackdrop.count);
      expect(dots.activeIndex, 0);
    });

    testWidgets('Get Started opens the referral sign-up', (tester) async {
      await pumpOnboarding(tester);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Join and start earning from day one'), findsOneWidget);
    });

    testWidgets('members can go straight to sign in', (tester) async {
      await pumpOnboarding(tester);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });
  });
}
