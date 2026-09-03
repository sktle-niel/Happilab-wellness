/// A cached body. Wrapping it keeps a cached `null` — an empty 200 — apart
/// from a miss.
final class CachedResponse {
  const CachedResponse(this.json);

  final Object? json;
}

/// In-memory TTL cache for GET responses.
///
/// A hit skips the network, the rate limiter and the retry budget, which is
/// what makes a re-visited screen instant instead of a spinner. It holds
/// decoded JSON, never credentials, and lives only as long as the process —
/// a session boundary clears it entirely.
class ResponseCache {
  ResponseCache({this.maxEntries = 64, DateTime Function()? clock})
    : assert(maxEntries > 0, 'A cache must hold at least one entry'),
      _clock = clock ?? DateTime.now;

  final int maxEntries;
  final DateTime Function() _clock;

  /// Insertion-ordered, oldest first; a read re-inserts, so eviction drops the
  /// least recently *used* entry rather than the least recently written.
  final Map<Uri, _Entry> _entries = <Uri, _Entry>{};

  /// The entry for [key] if it is still within its TTL.
  CachedResponse? readFresh(Uri key) {
    final entry = _entries.remove(key);
    if (entry == null) return null;
    _entries[key] = entry;
    return _clock().isAfter(entry.expiresAt)
        ? null
        : CachedResponse(entry.json);
  }

  /// The entry for [key] regardless of age — the offline fallback, for when
  /// stale data beats an error screen.
  CachedResponse? readStale(Uri key) {
    final entry = _entries[key];
    return entry == null ? null : CachedResponse(entry.json);
  }

  void write(Uri key, Object? json, Duration ttl) {
    _entries.remove(key);
    if (_entries.length >= maxEntries) _entries.remove(_entries.keys.first);
    _entries[key] = _Entry(json, _clock().add(ttl));
  }

  void clear() => _entries.clear();
}

final class _Entry {
  const _Entry(this.json, this.expiresAt);

  final Object? json;
  final DateTime expiresAt;
}
