import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/shared/domain/profile_photo.dart';
import 'package:happilab/shared/widgets/app_button.dart';

import '../../support/fake_photo_library.dart';
import '../../support/harness.dart';

void main() {
  Finder continueButton() => find.widgetWithText(AppButton, 'Continue');

  Future<void> pumpChoosePhoto(
    WidgetTester tester, {
    FakePhotoLibrary? library,
  }) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      testApp(initialRoute: AppRoutes.choosePhoto, photoLibrary: library),
    );
    await tester.pump();
  }

  group('ChoosePhotoScreen', () {
    testWidgets('offers the avatars and the phone, and waits for a choice', (
      tester,
    ) async {
      await pumpChoosePhoto(tester);

      expect(find.text('Add your photo'), findsOneWidget);
      expect(find.text('Boy'), findsOneWidget);
      expect(find.text('Girl'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Remove'), findsNothing);
      expect(tester.widget<AppButton>(continueButton()).onPressed, isNull);
    });

    testWidgets('an avatar opens the way in', (tester) async {
      final library = FakePhotoLibrary();
      await pumpChoosePhoto(tester, library: library);

      await tester.tap(find.text('Girl'));
      await tester.pump();
      await tester.pump();

      expect(library.adoptions, [Avatar.girl]);
      expect(tester.widget<AppButton>(continueButton()).onPressed, isNotNull);

      await tester.tap(continueButton());
      // Explicit pumps, not pumpAndSettle: home animates forever.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Add your photo'), findsNothing);
    });
  });
}
