import 'dart:io';

import 'package:happilab/core/errors/result.dart';
import 'package:happilab/shared/domain/profile_photo.dart';

/// A [PhotoLibrary] a test scripts: what it has kept, and what opening a
/// source or adopting an avatar comes back with.
class FakePhotoLibrary implements PhotoLibrary {
  FakePhotoLibrary({this.stored});

  /// What [restore] answers, and what a successful replacement updates.
  File? stored;

  /// What opening a source comes back with — backing out, by default.
  Future<Result<File?>> Function(PhotoSource source) onPick = (_) async =>
      const Success(null);

  /// What adopting an avatar comes back with — a file named after it.
  Future<Result<File?>> Function(Avatar avatar) onAdopt = (avatar) async =>
      Success(File('${avatar.name}.jpg'));

  final List<PhotoSource> picks = [];
  final List<Avatar> adoptions = [];
  int restores = 0;
  int discards = 0;

  @override
  Future<File?> restore() async {
    restores++;
    return stored;
  }

  @override
  Future<Result<File?>> pick(PhotoSource source) async {
    picks.add(source);
    return _keep(await onPick(source));
  }

  @override
  Future<Result<File?>> adopt(Avatar avatar) async {
    adoptions.add(avatar);
    return _keep(await onAdopt(avatar));
  }

  @override
  Future<void> discard() async {
    discards++;
    stored = null;
  }

  Result<File?> _keep(Result<File?> replacement) {
    stored = replacement.valueOrNull ?? stored;
    return replacement;
  }
}
