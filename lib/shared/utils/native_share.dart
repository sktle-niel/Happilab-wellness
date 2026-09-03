import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// Hands text plus an optional picture to another app through the platform's
/// share intent — the one thing no URL scheme can carry.
///
/// Hand-rolled over `share_plus` deliberately: the plugin can only open the
/// system chooser, and the share sheets promise a *specific* app per disc.
abstract final class NativeShare {
  static const MethodChannel _channel = MethodChannel('happilab/share');

  /// True when the target app took the share. False when it is not installed,
  /// or the platform carries no share channel (tests, and iOS until it gains
  /// its own side) — the caller owns what the member sees then.
  static Future<bool> send({
    required String text,
    File? image,
    String? toPackage,
  }) async {
    try {
      final sent = await _channel.invokeMethod<bool>('send', {
        'text': text,
        'imagePath': image?.path,
        'package': toPackage,
      });
      return sent ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Backs the member's Facebook story with [image] — a different intent from
  /// a plain send, and one Facebook only honours alongside the app id the
  /// manifest carries. False follows the same rules as [send].
  static Future<bool> sendToFacebookStory({required File image}) async {
    try {
      final sent = await _channel.invokeMethod<bool>('sendToStory', {
        'imagePath': image.path,
      });
      return sent ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Resolves [provider] through the regular image cache and writes the
  /// picture to the one temporary PNG the share intent attaches. Null when it
  /// cannot be loaded — callers then share the text alone rather than fail.
  static Future<File?> writeTempImage(ImageProvider provider) async {
    try {
      final image = await resolveImage(provider)
          .timeout(const Duration(seconds: 8));
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;
      final file = File('${Directory.systemTemp.path}/product-share.png');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// One frame of [provider], through the regular image cache — what both the
  /// temp-file writer above and the story card renderer draw from.
  static Future<ui.Image> resolveImage(ImageProvider provider) {
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (frame, _) {
        if (!completer.isCompleted) completer.complete(frame.image);
        stream.removeListener(listener);
      },
      onError: (error, _) {
        if (!completer.isCompleted) completer.completeError(error);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
}
