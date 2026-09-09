import 'dart:io';

import 'package:flutter/services.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../domain/profile_photo.dart';

/// [PhotoLibrary] over the channel `MainActivity` answers: the picture is
/// chosen, shrunk and kept on the native side, and only its path crosses.
///
/// iOS carries no channel yet, so there — and in tests — every source reads
/// as unavailable and nothing is ever kept, the way `NativeShare` degrades.
class NativePhotoLibrary implements PhotoLibrary {
  const NativePhotoLibrary();

  static const MethodChannel _channel = MethodChannel('happilab/profile_photo');

  @override
  Future<File?> restore() async {
    final kept = await _ask<String>('current', const UnknownException());
    return _toFile(kept.valueOrNull);
  }

  @override
  Future<Result<File?>> pick(PhotoSource source) async {
    final method = switch (source) {
      PhotoSource.gallery => 'pick',
      PhotoSource.camera => 'capture',
    };
    final picked = await _ask<String>(
      method,
      UnknownException(source.unavailableMessage),
    );
    return picked.map(_toFile);
  }

  @override
  Future<Result<File?>> attach(PhotoSource source) async {
    final method = switch (source) {
      PhotoSource.gallery => 'attach',
      PhotoSource.camera => 'snap',
    };
    final handed = await _ask<String>(
      method,
      UnknownException(source.unavailableMessage),
    );
    return handed.map(_toFile);
  }

  /// The bundle is Dart's to read, the files folder is the platform's to
  /// write: the avatar is staged in the cache between the two.
  @override
  Future<Result<File?>> adopt(Avatar avatar) async {
    final staged = File('${Directory.systemTemp.path}/avatar.jpg');
    try {
      final bytes = await rootBundle.load(avatar.asset);
      await staged.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );
    } on FileSystemException {
      return const Failure(UnknownException(Avatar.unavailableMessage));
    }
    final kept = await _ask<String>(
      'keep',
      const UnknownException(Avatar.unavailableMessage),
      arguments: {'path': staged.path},
    );
    return kept.map(_toFile);
  }

  @override
  Future<void> discard() async {
    await _ask<void>('remove', const UnknownException());
  }

  /// The channel's answer to [method], or [ifUnavailable] when the platform
  /// carries no channel or refused the call.
  Future<Result<T?>> _ask<T>(
    String method,
    AppException ifUnavailable, {
    Map<String, Object?>? arguments,
  }) async {
    try {
      return Success(await _channel.invokeMethod<T>(method, arguments));
    } on PlatformException {
      return Failure(ifUnavailable);
    } on MissingPluginException {
      return Failure(ifUnavailable);
    }
  }

  static File? _toFile(String? path) => path == null ? null : File(path);
}
