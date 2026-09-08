import 'package:video_player/video_player.dart';

/// Creates and initialises a controller for a clip — bundled, or served by
/// URL — or returns null when the platform cannot play it.
///
/// The catch is deliberately broad: a missing decoder throws
/// `PlatformException`, an absent plugin throws `MissingPluginException`, and a
/// host with no video surface at all throws `UnimplementedError`. None of them
/// should take a screen down — every caller has a placeholder to stand in.
/// The caller still owns the mounted check and, eventually, `dispose()`.
Future<VideoPlayerController?> initializeClip(String source) async {
  final controller = _controllerFor(source);
  try {
    await controller.initialize();
  } catch (_) {
    await controller.dispose();
    return null;
  }
  return controller;
}

/// A clip is bundled unless it names a web address — what the API will hand
/// over when it holds the footage.
VideoPlayerController _controllerFor(String source) {
  final url = Uri.tryParse(source);
  if (url != null && (url.isScheme('https') || url.isScheme('http'))) {
    return VideoPlayerController.networkUrl(url);
  }
  return VideoPlayerController.asset(source);
}
