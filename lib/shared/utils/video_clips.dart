import 'package:video_player/video_player.dart';

/// Creates and initialises a controller for a bundled clip, or returns null
/// when the platform cannot play it.
///
/// The catch is deliberately broad: a missing decoder throws
/// `PlatformException`, an absent plugin throws `MissingPluginException`, and a
/// host with no video surface at all throws `UnimplementedError`. None of them
/// should take a screen down — every caller has a placeholder to stand in.
/// The caller still owns the mounted check and, eventually, `dispose()`.
Future<VideoPlayerController?> initializeAssetClip(String assetPath) async {
  final controller = VideoPlayerController.asset(assetPath);
  try {
    await controller.initialize();
  } catch (_) {
    await controller.dispose();
    return null;
  }
  return controller;
}
