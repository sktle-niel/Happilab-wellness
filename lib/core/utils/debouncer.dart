import 'dart:async';

import 'package:flutter/foundation.dart';

/// Collapses a burst of calls into the last one.
///
/// The first line of defence for request volume: a search field that fires per
/// keystroke will exhaust a rate limit before the user finishes typing.
/// Always `dispose()` it with the widget or controller that owns it.
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 350)});

  final Duration duration;
  Timer? _timer;

  bool get isPending => _timer?.isActive ?? false;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() => cancel();
}
