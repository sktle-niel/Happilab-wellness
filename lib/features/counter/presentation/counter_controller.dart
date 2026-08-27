import 'package:flutter/foundation.dart';

/// State holder for the counter screen.
///
/// Keeping state and behaviour here leaves the widget dumb — it renders what
/// the controller exposes and forwards intents back — and lets this logic be
/// unit tested without pumping a widget tree.
class CounterController extends ChangeNotifier {
  CounterController({int initialValue = 0, this.step = 1})
    : assert(step > 0, 'Step must move the counter forward'),
      _value = initialValue;

  final int step;
  int _value;

  int get value => _value;

  bool get canReset => _value != 0;

  void increment() {
    _value += step;
    notifyListeners();
  }

  void reset() {
    if (!canReset) return;
    _value = 0;
    notifyListeners();
  }
}
