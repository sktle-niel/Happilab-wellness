import 'package:flutter_test/flutter_test.dart';
import 'package:happilab/core/network/response_cache.dart';

void main() {
  group('ResponseCache', () {
    late DateTime now;
    late ResponseCache cache;

    final key = Uri.parse('https://api.test.local/v1/profile');
    const ttl = Duration(minutes: 1);

    setUp(() {
      now = DateTime(2026, 1, 1);
      cache = ResponseCache(maxEntries: 2, clock: () => now);
    });

    test('misses on a key never written', () {
      expect(cache.readFresh(key), isNull);
      expect(cache.readStale(key), isNull);
    });

    test('serves a written entry within its TTL', () {
      cache.write(key, {'name': 'Ivy'}, ttl);

      expect(cache.readFresh(key)?.json, {'name': 'Ivy'});
    });

    test('a cached null body is a hit, not a miss', () {
      cache.write(key, null, ttl);

      expect(cache.readFresh(key), isNotNull);
      expect(cache.readFresh(key)?.json, isNull);
    });

    test('expires a fresh read but keeps the stale one', () {
      cache.write(key, 'value', ttl);
      now = now.add(ttl + const Duration(seconds: 1));

      expect(cache.readFresh(key), isNull);
      expect(cache.readStale(key)?.json, 'value');
    });

    test('evicts the least recently used entry beyond capacity', () {
      final second = Uri.parse('https://api.test.local/v1/rewards');
      final third = Uri.parse('https://api.test.local/v1/feed');
      cache.write(key, 'first', ttl);
      cache.write(second, 'second', ttl);

      // Touch the oldest so the middle one is now least recently used.
      cache.readFresh(key);
      cache.write(third, 'third', ttl);

      expect(cache.readFresh(key)?.json, 'first');
      expect(cache.readFresh(second), isNull);
      expect(cache.readFresh(third)?.json, 'third');
    });

    test('rewriting a key refreshes it without evicting others', () {
      final second = Uri.parse('https://api.test.local/v1/rewards');
      cache.write(key, 'first', ttl);
      cache.write(second, 'second', ttl);

      cache.write(key, 'updated', ttl);

      expect(cache.readFresh(key)?.json, 'updated');
      expect(cache.readFresh(second)?.json, 'second');
    });

    test('clear drops everything, stale reads included', () {
      cache.write(key, 'value', ttl);

      cache.clear();

      expect(cache.readStale(key), isNull);
    });
  });
}
