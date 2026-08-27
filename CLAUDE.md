# CLAUDE.md — happilab

Project instructions for Claude Code. These rules apply to **every** session and every change in this
repo. Flutter 3.47 / Dart 3.13, Material 3, no state-management or HTTP package — the app ships with
its own thin core layer.

## Role

Act as a **senior frontend developer and architect**. Make the design decision first, then write the
smallest correct implementation of it. No tutorial code, no boilerplate ceremony, no demo comments
left behind, no speculative abstractions for requirements that do not exist yet.

## Non-negotiables

1. **Reusable by default.** Look for an existing widget, helper or service before writing a new one.
   If it exists — reuse it. If it does not and it will be needed twice — build it in `shared/` or
   `core/`, not inline.
2. **No spaghetti.** One responsibility per widget, per function, per file. If a `build()` scrolls
   past ~50 lines, split it into named widgets. No nested ternaries or business rules inside a widget
   tree.
3. **Short and efficient.** The shortest code that stays readable wins. Delete dead code and unused
   imports as you go. Duplicated blocks get extracted, never copy-pasted.
4. **Fast at runtime.** `const` wherever valid, `ListView.builder` over building all children, no
   expensive work inside `build()`, rebuild the smallest possible subtree.
5. **Secure by default.** See [Security](#security) — it is not a later phase.
6. **Rate limited by default.** See [Rate limits & network discipline](#rate-limits--network-discipline).

## Architecture

Layered, feature-first. **Dependencies point inward and downward only:**

```
features/  ──▶  shared/  ──▶  core/  ──▶  (Flutter SDK)
   │
   └──▶ app/ only for theme tokens and route names
```

- `core/` knows nothing about features, widgets or screens. Pure Dart where possible.
- `shared/` holds cross-feature UI. It never imports a feature.
- `features/` never import each other. A shared need is promoted to `shared/` or `core/`.
- **No singletons, no service locators.** `AppDependencies` is the single composition root; services
  reach widgets through `AppScope.of(context)`. Anything constructing its own `ApiClient` is a bug.
- **Every boundary is an interface.** `HttpTransport`, `TokenStore` — depend on the contract so the
  implementation can be swapped in a test without touching feature code.
- **Failures are values, not exceptions.** Repositories return `Result<T>`; the sealed `AppException`
  set forces every caller to handle the sad path. Raw exceptions never cross into `features/`.

### Feature slice

A feature owns its whole vertical. Create only the layers it actually needs:

```
features/<name>/
  data/          # DTOs + repository implementation (talks to ApiClient)
  domain/        # entities, repository interface, use cases — pure Dart, no Flutter
  presentation/  # screen + controller + widgets/
```

The `counter` feature is presentation-only on purpose: it has no data source, so inventing `data/`
and `domain/` for it would be architecture theatre. Add a layer when the feature earns it.

## Folder structure

```
lib/
  main.dart                        # entry point only: build deps, runApp
  app/                             # application shell
    app.dart                       # HappilabApp: scope + theme + router
    di/app_dependencies.dart       # composition root — every service built once
    di/app_scope.dart              # InheritedWidget exposing dependencies
    router/app_routes.dart         # route name constants
    router/app_router.dart         # route table + unknown-route fallback
    theme/app_colors.dart          # color seeds
    theme/app_tokens.dart          # spacing, radii, durations
    theme/app_typography.dart      # type scale
    theme/app_theme.dart           # light/dark ThemeData
  core/                            # framework-level, feature-agnostic
    config/app_config.dart         # flavors + --dart-define values, TLS enforced
    errors/app_exception.dart      # sealed failure set
    errors/result.dart             # Result<T> = Success | Failure
    logging/app_logger.dart        # redacted, level-filtered logging
    network/http_transport.dart    # transport contract + request/response models
    network/io_http_transport.dart # dart:io implementation
    network/api_client.dart        # rate limit -> auth -> timeout -> retry -> Result
    network/rate_limiter.dart      # sliding-window limiter
    network/retry_policy.dart      # exponential backoff + jitter
    security/token_store.dart      # credential storage contract + in-memory impl
    security/secure_token_store.dart # Keychain / Android KeyStore implementation
    security/redactor.dart         # secret scrubbing for logs
    security/input_validator.dart  # validation + sanitising
    utils/debouncer.dart           # collapse call bursts
  features/<name>/                 # vertical slices (see above)
  shared/widgets/                  # AppScaffold, AppButton, AsyncView, ErrorView, Gap
test/
  core/ features/ support/         # mirrors lib/; support/ holds reusable fakes
```

Mirror this layout in `test/`. Create a folder when the first file needs it — never leave empty
scaffolding behind.

## Widget rules

- Prefer `StatelessWidget`; `StatefulWidget` only when local state or a lifecycle genuinely exists.
- Extract widgets into **classes**, never into `Widget _buildX()` methods — classes get `const` and a
  narrower rebuild scope.
- Every constructor: `const` + named parameters + `required` where mandatory; `super.key` last.
- Never hardcode a color, text style, radius or spacing in a screen. Use `Theme.of(context)`,
  `AppSpacing`, `AppRadius`, `AppDuration`.
- Screens compose `AppScaffold`; failures render `ErrorView`; async reads render `AsyncView`.
- Any control the user can tap must go inert while its action is in flight — double submits are bugs.

## State management

- One `ChangeNotifier` controller per screen, owned by the screen's `State` and disposed in
  `dispose()`.
- Rebuild through `ListenableBuilder` / `ValueListenableBuilder` around the **smallest** subtree.
- Controllers hold state and intent handlers. Business rules live in `domain/`, not in the controller;
  widgets stay dumb.
- Never call `setState` from a callback that can fire after disposal — guard with `mounted`.

## Dart rules

- `final` over `var`; `late` only when unavoidable.
- Sealed classes plus exhaustive `switch` expressions for closed sets (see `Result`, `AppException`).
- Small pure functions. Collection-if / collection-for / spread over imperative list building.
- Every `async` path handles failure. No empty `catch {}`, no swallowed errors.
- The analyzer must be clean (`flutter_lints`). Warnings are not "later".

## Security

Treat everything outside the process as hostile.

- **No secrets in the repo.** Endpoints, keys and flags arrive through `--dart-define` and
  `AppConfig.fromEnvironment()`. Never commit a key, token, `.env` file or keystore.
- **TLS only.** `AppConfig` rejects a non-`https` base URL outside local dev. Never override
  `badCertificateCallback`, never enable cleartext traffic.
- **Credentials never touch plain storage.** Go through the `TokenStore` contract; production binds
  it to `SecureTokenStore` (`flutter_secure_storage`: Keychain on iOS, KeyStore-wrapped AES-GCM on
  Android). `SharedPreferences`, plain files and query strings are not credential stores. Keychain
  items stay `unlocked_this_device` and never `synchronizable` — a synced token leaves the device.
  On 401/403 the token is cleared immediately.
- **Nothing leaves the device.** Android backup is off (`android:allowBackup="false"` plus
  `android/app/src/main/res/xml/data_extraction_rules.xml`, which blocks cloud backup and
  device-to-device transfer on API 31+). A restored token is a stale credential waiting to be
  replayed, and the KeyStore key it needs never travels with it.
- **Nothing sensitive reaches a log.** `AppLogger` redacts through `Redactor` and drops everything
  below `warning` in production. `print` is banned — the linter enforces it.
- **All input is untrusted.** Validate and sanitise with `InputValidator` before use, cap lengths, and
  assume the server validates again — a client-side check is UX, not a security control.
- **All output is untrusted too.** Parse responses defensively; a shape mismatch is a
  `DataFormatException`, never a crash. Never render server-supplied text as markup.
- **Errors tell an attacker nothing.** `AppException.message` is user-facing and generic; diagnostics
  go to the log, not to the screen.
- **Dependencies are attack surface.** Justify every new package, prefer the SDK, keep `pubspec.lock`
  committed, and never add a package to save five lines. The full approved list today is
  `cupertino_icons`, `flutter_secure_storage` (no SDK equivalent for platform-secure storage), and
  `flutter_lints` + `flutter_secure_storage_platform_interface` for development. Adding to it is a
  decision, not a reflex — networking, state and DI stay hand-rolled in `core/`.

## Rate limits & network discipline

Client-side throttling is a first-class requirement, not an optimisation. A retry storm or a rebuild
loop can flood the backend, burn the user's quota and get the client blocked.

- **Every outbound call goes through `ApiClient`.** No widget, controller or repository builds its own
  HTTP client or calls a transport directly.
- **`RateLimiter` guards every request** with a sliding window sized by
  `AppConfig.maxRequestsPerMinute`. Keep that at or below the backend's published quota.
- **Retries are bounded and jittered.** `RetryPolicy` retries only transient failures (408, 429, 5xx,
  timeouts, connection loss) with exponential backoff plus jitter. A 4xx is never retried — it only
  burns the limit.
- **Honour `Retry-After`.** A server-sent cooldown wins over local backoff, clamped so a bad header
  cannot freeze the UI.
- **Debounce user-driven traffic** (`Debouncer`, `AppDuration.debounce`) for search fields, filters and
  anything that fires per keystroke. Throttle scroll and resize handlers the same way.
- **Every request has a timeout** (`AppConfig.requestTimeout`). No unbounded awaits.
- **429 is a real state.** Surface `RateLimitedException` to the user as a wait, never as a silent
  failure or an instant retry loop.

## Performance

- `const` constructors everywhere valid; hoist constant widgets out of `build()`.
- Lazy lists (`.builder`) for anything that can grow; keys on reorderable children.
- No I/O, parsing or allocation-heavy work inside `build()`.
- Dispose everything with a lifecycle: controllers, timers, debouncers, subscriptions.
- Cache what is expensive and stable; never cache credentials.

## Naming

`UpperCamelCase` types, `lowerCamelCase` members, `snake_case.dart` files. Names state intent
(`AppButton`, `RateLimiter`, `sanitize`) — never `Widget1`, `data2`, `temp`, `helper`.

## Testing

- Unit-test logic that can break silently: the limiter, the retry policy, validators, controllers.
- Widget-test the states a user can actually reach — including empty, loading and error.
- Fakes live in `test/support/` and get reused. Never hit the real network in a test.
- Tests are deterministic: inject the clock, inject the transport, never sleep.

## Comments

Explain **why**, never **what**. No commented-out code, no template comments, no changelogs in source.
A comment that restates the line below it gets deleted.

## Definition of done

- [ ] Nothing duplicated that could have been reused.
- [ ] No file or `build()` turned into a monolith.
- [ ] Layering respected — no feature-to-feature import, no `core/` importing UI.
- [ ] Network path goes through `ApiClient`: rate limited, timed out, bounded retries.
- [ ] No secret, token or personal data in source, storage or logs.
- [ ] `const` applied where valid; everything disposable is disposed.
- [ ] `flutter analyze` clean and `flutter test` green.
- [ ] Smallest surface changed — no unrequested refactors, no stray files.

## Commands

```bash
flutter run       # run the app
flutter analyze   # static analysis — must be clean
flutter test      # run the suite
dart format lib test
```

Point the app at a real backend with build-time defines:

```bash
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=https://api.example.com --dart-define=API_MAX_REQUESTS_PER_MINUTE=60
```
