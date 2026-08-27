# Happilab

A Flutter app built on a layered, feature-first foundation with a secure, rate-limited network core.

The product features are not written yet. What exists today is the groundwork every screen will sit
on: theming, dependency injection, routing, failure handling, logging, credential storage, and an API
client that throttles and retries on its own. The `counter` feature is there as the reference example
of how a slice is put together.

**Stack:** Flutter 3.47 · Dart 3.13 · Material 3 · Android + iOS

## Getting started

**Requirements**

- Flutter 3.47 or newer (`flutter --version`)
- Android SDK with **platform `android-37`** installed — required by `flutter_secure_storage` 11
- iOS 15+ deployment target (already set), Xcode for iOS builds

```bash
flutter pub get
flutter run
```

Configuration is injected at build time — nothing sensitive lives in the repo:

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=API_MAX_REQUESTS_PER_MINUTE=60
```

| Define | Default | Purpose |
| --- | --- | --- |
| `APP_ENV` | `dev` | Flavor: `dev`, `staging`, `prod` |
| `API_BASE_URL` | `https://api.happilab.app` | API root. Must be `https` outside local dev |
| `API_MAX_REQUESTS_PER_MINUTE` | `60` | Client-side rate limit ceiling |

## Architecture

Dependencies point one way only:

```
features/  ──▶  shared/  ──▶  core/  ──▶  (Flutter SDK)
```

- **`core/`** — framework-level, feature-agnostic, pure Dart where possible. Knows nothing about UI.
- **`shared/`** — cross-feature widgets. Never imports a feature.
- **`features/`** — vertical slices (`data/` · `domain/` · `presentation/`). Never import each other.
- **`app/`** — the shell: composition root, routing, theme.

Two rules carry most of the weight:

**One composition root.** Every service is built once in `AppDependencies` and reaches widgets through
`AppScope.of(context)`. There are no singletons and no service locator, so any dependency can be
replaced in a test by passing a different instance.

**Failures are values.** Operations return `Result<T>` (`Success` | `Failure`) carrying a sealed
`AppException`. The compiler will not let a caller forget the sad path, and raw exceptions never cross
into feature code.

```dart
final result = await api.get('v1/profile', parse: Profile.fromJson);

return result.fold(
  (profile) => ProfileView(profile: profile),
  (error) => ErrorView(error: error, onRetry: _reload),
);
```

## Networking

`ApiClient` is the only way the app talks to the network. Every call runs the same pipeline:

```
rate limit ──▶ attach token ──▶ timeout ──▶ retry with jittered backoff ──▶ Result<T>
```

- **`RateLimiter`** — sliding window sized by `API_MAX_REQUESTS_PER_MINUTE`, so the app throttles
  itself before the backend has to.
- **`RetryPolicy`** — retries only transient failures (408, 429, 5xx, timeouts, connection loss) with
  exponential backoff plus jitter. A 4xx is never retried. A server `Retry-After` wins over local
  backoff.
- **`HttpTransport`** — the seam. `IoHttpTransport` is the real one; tests inject a fake and never
  touch the network.

## Security

- No secrets in the repo — endpoints and keys arrive through `--dart-define`.
- TLS enforced: `AppConfig` rejects a non-`https` base URL outside local dev.
- Tokens live in platform-secure storage (Keychain on iOS, KeyStore-wrapped AES-GCM on Android) and are
  cleared the moment the server returns 401/403.
- Android backup and device-to-device transfer are disabled, so a credential cannot leave the device.
- Every log line passes through `Redactor`; production drops anything below `warning`.
- Input is validated and sanitised on the way in, responses are parsed defensively on the way out.

## Testing

```bash
flutter analyze         # must be clean
flutter test            # 9 tests
dart format lib test
```

Tests mirror `lib/`. Reusable fakes live in `test/support/`. Everything is deterministic — the clock
and the transport are injected, and nothing sleeps.

## Project layout

```
lib/
  main.dart          entry point only
  app/               shell: DI, router, theme tokens
  core/              config, errors, logging, network, security, utils
  features/          vertical slices (counter is the reference example)
  shared/widgets/    AppScaffold, AppButton, AsyncView, ErrorView, Gap
test/                mirrors lib/, plus support/ for fakes
```

## Contributing

[`CLAUDE.md`](CLAUDE.md) holds the engineering rules this repo is built on — layering, widget and Dart
conventions, security requirements, rate-limit discipline, and the definition of done. Read it before
opening a PR; it is also the instruction file for Claude Code sessions in this project.
