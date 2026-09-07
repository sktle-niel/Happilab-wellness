import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/errors/result.dart';
import 'package:happilab/shared/domain/profile_photo.dart';

import '../support/fake_photo_library.dart';

void main() {
  group('ProfilePhoto', () {
    test('load reads back the kept picture, once', () async {
      final library = FakePhotoLibrary(stored: File('kept.jpg'));
      final photo = ProfilePhoto(library: library);

      await photo.load();
      await photo.load();

      expect(photo.file?.path, 'kept.jpg');
      expect(photo.hasPhoto, isTrue);
      expect(library.restores, 1);
    });

    test('change keeps what the member chose and tells listeners', () async {
      final library = FakePhotoLibrary()
        ..onPick = (_) async => Success(File('chosen.jpg'));
      final photo = ProfilePhoto(library: library);
      var notified = 0;
      photo.addListener(() => notified++);

      final result = await photo.change(PhotoSource.gallery);

      expect(result.isSuccess, isTrue);
      expect(photo.file?.path, 'chosen.jpg');
      expect(library.picks, [PhotoSource.gallery]);
      expect(notified, 2, reason: 'once going busy, once coming back');
    });

    test('wear puts on the avatar', () async {
      final library = FakePhotoLibrary();
      final photo = ProfilePhoto(library: library);

      final result = await photo.wear(Avatar.girl);

      expect(result.isSuccess, isTrue);
      expect(photo.file?.path, 'girl.jpg');
      expect(library.adoptions, [Avatar.girl]);
    });

    test('backing out keeps the picture there was', () async {
      final library = FakePhotoLibrary(stored: File('kept.jpg'));
      final photo = ProfilePhoto(library: library);
      await photo.load();

      final result = await photo.change(PhotoSource.camera);

      expect(result, isA<Success<File?>>());
      expect(photo.file?.path, 'kept.jpg');
    });

    test('a source that will not open says so and keeps the picture', () async {
      final library = FakePhotoLibrary(stored: File('kept.jpg'))
        ..onPick = (source) async =>
            Failure(UnknownException(source.unavailableMessage));
      final photo = ProfilePhoto(library: library);
      await photo.load();

      final result = await photo.change(PhotoSource.camera);

      expect(result.errorOrNull?.message, 'Could not open the camera.');
      expect(photo.file?.path, 'kept.jpg');
    });

    test(
      'is busy while a replacement runs, and will not start a second',
      () async {
        final gate = Completer<Result<File?>>();
        final library = FakePhotoLibrary()..onPick = (_) => gate.future;
        final photo = ProfilePhoto(library: library);

        final first = photo.change(PhotoSource.camera);
        expect(photo.isBusy, isTrue);

        await photo.wear(Avatar.boy);
        expect(library.adoptions, isEmpty);

        gate.complete(const Success(null));
        await first;
        expect(photo.isBusy, isFalse);
      },
    );

    test(
      'remove discards the kept picture and goes back to initials',
      () async {
        final library = FakePhotoLibrary(stored: File('kept.jpg'));
        final photo = ProfilePhoto(library: library);
        await photo.load();

        await photo.remove();

        expect(photo.hasPhoto, isFalse);
        expect(library.discards, 1);
        expect(library.stored, isNull);
      },
    );
  });
}
