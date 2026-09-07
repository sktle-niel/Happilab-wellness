import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/router/app_routes.dart';
import 'package:happilab/app/theme/app_tokens.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/errors/result.dart';
import 'package:happilab/features/profile/presentation/widgets/profile_photo_picker.dart';
import 'package:happilab/shared/domain/profile_photo.dart';
import 'package:happilab/shared/widgets/avatar_circle.dart';

import '../../support/fake_photo_library.dart';
import '../../support/harness.dart';

void main() {
  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byType(ProfilePhotoPicker));
    await settleSheet(tester);
  }

  Future<void> pumpEditProfile(
    WidgetTester tester, {
    FakePhotoLibrary? library,
  }) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      testApp(initialRoute: AppRoutes.editProfile, photoLibrary: library),
    );
    await tester.pump();
  }

  AvatarCircle avatarOf(WidgetTester tester) =>
      tester.widget<AvatarCircle>(find.byType(AvatarCircle));

  group('EditProfileScreen photo', () {
    testWidgets('the avatar opens the sheet of avatars and sources', (
      tester,
    ) async {
      await pumpEditProfile(tester);

      await openSheet(tester);

      expect(find.text('Profile photo'), findsOneWidget);
      expect(find.text('Boy'), findsOneWidget);
      expect(find.text('Girl'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Remove'), findsNothing);
    });

    testWidgets('choosing an avatar puts it on', (tester) async {
      final library = FakePhotoLibrary();
      await pumpEditProfile(tester, library: library);

      await openSheet(tester);
      await tester.tap(find.text('Girl'));
      await settleSheet(tester);

      expect(library.adoptions, [Avatar.girl]);
      expect(avatarOf(tester).photo?.path, 'girl.jpg');
    });

    testWidgets('choosing the gallery keeps the picture it gives back', (
      tester,
    ) async {
      final library = FakePhotoLibrary()
        ..onPick = (_) async => Success(File('chosen.jpg'));
      await pumpEditProfile(tester, library: library);

      await openSheet(tester);
      await tester.tap(find.text('Gallery'));
      await settleSheet(tester);

      expect(library.picks, [PhotoSource.gallery]);
      expect(avatarOf(tester).photo?.path, 'chosen.jpg');

      await openSheet(tester);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('removing the picture goes back to initials', (tester) async {
      final library = FakePhotoLibrary(stored: File('kept.jpg'));
      await pumpEditProfile(tester, library: library);

      await openSheet(tester);
      await tapVisible(tester, find.text('Remove'));
      await settleSheet(tester);

      expect(library.discards, 1);
      expect(avatarOf(tester).photo, isNull);
    });

    testWidgets('a camera that will not open is explained', (tester) async {
      final library = FakePhotoLibrary()
        ..onPick = (source) async =>
            Failure(UnknownException(source.unavailableMessage));
      await pumpEditProfile(tester, library: library);

      await openSheet(tester);
      await tester.tap(find.text('Camera'));
      await settleSheet(tester);

      expect(find.text('Could not open the camera.'), findsOneWidget);
      // Let the toast withdraw so no timer outlives the test.
      await tester.pump(AppDuration.toast);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
