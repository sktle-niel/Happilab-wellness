import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/app/theme/theme_controller.dart';
import 'package:happilab/core/errors/app_exception.dart';
import 'package:happilab/core/security/token_store.dart';

/// A store that refuses every write, the way a locked keystore would.
final class _RefusingStore implements TokenStore {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String token) async =>
      throw const SecureStorageException();

  @override
  Future<void> clear() async {}
}

/// Counts how often it is read, to prove the restore happens once.
final class _CountingStore implements TokenStore {
  int reads = 0;
  String? _kept;

  @override
  Future<String?> read() async {
    reads++;
    return _kept;
  }

  @override
  Future<void> write(String token) async => _kept = token;

  @override
  Future<void> clear() async => _kept = null;
}

void main() {
  group('ThemeController', () {
    ThemeController build(TokenStore store) {
      final controller = ThemeController(store: store);
      addTearDown(controller.dispose);
      return controller;
    }

    test('starts light and restores dark from the last launch', () async {
      final store = InMemoryTokenStore();
      await store.write('dark');
      final controller = build(store);
      expect(controller.isDark, isFalse);

      await controller.restore();

      expect(controller.mode, ThemeMode.dark);
    });

    test('keeps the choice for the next launch', () async {
      final store = InMemoryTokenStore();
      final controller = build(store);

      controller.setDark(true);
      await pumpEventQueue();
      expect(await store.read(), 'dark');

      controller.setDark(false);
      await pumpEventQueue();
      expect(await store.read(), isNull);
    });

    test('still switches when the store will not keep it', () async {
      final controller = build(_RefusingStore());
      var notified = 0;
      controller.addListener(() => notified++);

      controller.setDark(true);
      await pumpEventQueue();

      expect(controller.isDark, isTrue);
      expect(notified, 1);
    });

    test('restores once, however often it is asked', () async {
      final store = _CountingStore();
      final controller = build(store);

      await controller.restore();
      await controller.restore();

      expect(store.reads, 1);
    });
  });
}
