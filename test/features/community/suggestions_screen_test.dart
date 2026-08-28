import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/shared/domain/catalogue.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpSuggestions(WidgetTester tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(testApp(initialRoute: AppRoutes.suggestions));
    await tester.pump();
  }

  /// A sheet animates in over a few frames after the tap.
  Future<void> settleSheet(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('SuggestionsScreen', () {
    testWidgets('share opens a sheet with every storefront', (tester) async {
      await pumpSuggestions(tester);

      await tester.tap(find.bySemanticsLabel('Share Sakura Glow Soap'));
      await settleSheet(tester);

      expect(find.text('Share Sakura Glow Soap'), findsOneWidget);
      expect(find.text('Copy link'), findsOneWidget);
      for (final platform in SharePlatform.values) {
        expect(find.text(platform.label), findsOneWidget);
      }
    });

    testWidgets('cancel closes the sheet', (tester) async {
      await pumpSuggestions(tester);
      await tester.tap(find.bySemanticsLabel('Share Sakura Glow Soap'));
      await settleSheet(tester);

      await tester.tap(find.text('Cancel'));
      await settleSheet(tester);

      expect(find.text('Share Sakura Glow Soap'), findsNothing);
    });
  });

  group('Product.shareLink', () {
    test('searches the store for the product and carries the code', () {
      final link = Product.showcase.first.shareLink(
        SharePlatform.shopee,
        'FCV-IVY24',
      );

      expect(link.host, 'shopee.ph');
      expect(link.queryParameters['keyword'], 'Sakura Glow Soap');
      expect(link.queryParameters['ref'], 'FCV-IVY24');
    });

    test('prefers a real listing when the catalogue has one', () {
      const product = Product(
        name: 'Soap',
        blurb: '',
        price: '₱1',
        pointsRange: '1',
        imageUrl: '',
        storeLinks: {SharePlatform.lazada: 'https://www.lazada.com.ph/p/soap'},
      );

      final link = product.shareLink(SharePlatform.lazada, 'CODE');

      expect(link.path, '/p/soap');
      expect(link.queryParameters, {'ref': 'CODE'});
    });
  });
}
