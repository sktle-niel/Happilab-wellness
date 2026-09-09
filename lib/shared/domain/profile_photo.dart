import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/errors/result.dart';

/// Where a new profile picture comes from.
enum PhotoSource {
  gallery('Could not open your photos.'),
  camera('Could not open the camera.');

  const PhotoSource(this.unavailableMessage);

  /// What the member reads when this source will not open.
  final String unavailableMessage;
}

/// The bundled stand-ins a member can wear instead of a photo of their own —
/// placeholder art until the real set is drawn.
enum Avatar {
  boy('Boy', 'assets/images/avatars/boy.jpg'),
  girl('Girl', 'assets/images/avatars/girl.jpg');

  const Avatar(this.label, this.asset);

  final String label;
  final String asset;

  /// What the member reads when an avatar could not be kept.
  static const String unavailableMessage = 'Could not use that avatar.';
}

/// The platform's side of the profile picture: opening a source, keeping what
/// was chosen between launches, and letting it go.
abstract interface class PhotoLibrary {
  /// The picture kept from an earlier launch, if there is one.
  Future<File?> restore();

  /// Opens [source] and keeps what the member chooses. A null success is the
  /// member backing out; a failure is the source not opening, or the picture
  /// not reading.
  Future<Result<File?>> pick(PhotoSource source);

  /// Keeps [avatar] as the picture, the same way a chosen photo is kept.
  Future<Result<File?>> adopt(Avatar avatar);

  /// Opens [source] for a picture to send, not to wear: it is handed over
  /// and the profile picture stays as it is. Same answers as [pick].
  Future<Result<File?>> attach(PhotoSource source);

  /// Forgets the kept picture.
  Future<void> discard();
}

/// The member's profile picture, observable.
///
/// Every avatar of the member draws from here, so a change on the edit screen
/// reaches the home bar and the profile page in the same frame. The picture
/// stays on this device until the API can hold it, and leaves with the
/// session — the next member to sign in on the phone must never wear it.
class ProfilePhoto extends ChangeNotifier {
  ProfilePhoto({required this._library});

  final PhotoLibrary _library;

  File? _file;
  bool _isBusy = false;
  Future<void>? _loading;

  File? get file => _file;

  bool get hasPhoto => _file != null;

  /// True from the moment a replacement starts until the picture is kept —
  /// the avatar goes inert meanwhile.
  bool get isBusy => _isBusy;

  /// Reads back the picture kept from an earlier launch, once — later calls
  /// await the same read, so any avatar can ask without racing another.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    final file = await _library.restore();
    if (file == null) return;
    _file = file;
    notifyListeners();
  }

  /// Opens [source] and keeps what the member chooses. The avatars follow on
  /// their own; the result is for the caller to word a failure.
  Future<Result<File?>> change(PhotoSource source) =>
      _replace(() => _library.pick(source));

  /// Puts on [avatar]. Same contract as [change].
  Future<Result<File?>> wear(Avatar avatar) =>
      _replace(() => _library.adopt(avatar));

  /// Back to initials.
  Future<void> remove() async {
    await _library.discard();
    if (_file == null) return;
    _file = null;
    notifyListeners();
  }

  Future<Result<File?>> _replace(Future<Result<File?>> Function() next) async {
    if (_isBusy) return const Success(null);
    _setBusy(true);
    final picked = await next();
    final file = picked.valueOrNull;
    if (file != null) _file = file;
    _setBusy(false);
    return picked;
  }

  void _setBusy(bool busy) {
    _isBusy = busy;
    notifyListeners();
  }
}
