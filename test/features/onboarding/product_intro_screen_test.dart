import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/features/onboarding/domain/product_highlight.dart';
import 'package:happilab/features/onboarding/presentation/product_intro_screen.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpShowcase(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.productIntro));
    await tester.pump(const Duration(milliseconds: 1600));
  }

  group('ProductIntroScreen', () {
    testWidgets('shows every product with its price and points', (
      tester,
    ) async {
      await pumpShowcase(tester);

      for (final product in ProductHighlight.showcase) {
        expect(find.text(product.name), findsOneWidget);
        expect(find.text(product.earnLine), findsOneWidget);
      }
    });

    testWidgets('hands over to onboarding once it has held', (tester) async {
      await pumpShowcase(tester);
      expect(find.text('Our Products'), findsOneWidget);

      await tester.pump(ProductIntroScreen.hold);
      // Explicit pumps, not pumpAndSettle: onboarding animates its backdrop
      // forever, so settling would run the clock into the next stage.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.text('Our Products'), findsNothing);
      expect(find.text('Get Started'), findsOneWidget);
    });
  });
}
