# AC Falcon Crest Ventures

A Flutter referral app for the Falcon Crest programme. A member shares their code, earns points on
every order it brings in — not just the first — and cashes those points out to GCash or Maya at a peso
apiece. The app is the whole loop: the catalogue, the share sheet, the referral ledger, the payout,
and the community that keeps people coming back.

The screens are built and run on placeholder data. Every figure one shows comes from a single model in
`shared/domain/`, so the day the API exists it is a data source that changes, not a widget tree.

**Stack:** Flutter 3.47 · Dart 3.13 · Material 3 · Android + iOS

## What ships

| Slice | Screens |
| --- | --- |
| `onboarding` | Splash, the product showcase, and a three-stage intro told over video |
| `auth` | Sign in and create account, with the password policy checked as it is typed |
| `home` | Points balance, affiliate banner, product grid, and the share sheet behind it |
| `referrals` | How the programme works, and the member's own referral ledger |
| `rewards` | Cash out — preset amounts, payout method, editable payout number, receipt |
| `community` | News feed, member stories with video, and a suggestion box |
| `notifications` | The activity a member has not read yet |
| `profile` | Profile, edit profile, account activity |
| `support` | Help centre and programme terms |

Five of those live behind the bottom bar (`AppTab`); everything else is pushed on top of a tab and
carries a back button.

**The design system** is the rest of it. `app/theme/` holds one light palette and one dark one, plus
the spacing, radius and duration tokens every screen reads — nothing hardcodes a colour or a gap.
`shared/widgets/` holds the chrome: `AppScaffold`, `AppCard`, `AppButton`, `AppTextField`, the
`AppLoader` and `AppToast`, `AsyncView` and `ErrorView` for the states a screen can actually reach.
Two screens spelling out the same `Scaffold` is a bug here, not a style.

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
- **`shared/`** — cross-feature widgets and models. Never imports a feature.
- **`features/`** — vertical slices (`data/` · `domain/` · `presentation/`). Never import each other.
- **`app/`** — the shell: composition root, routing, theme, the tab bar.

Three rules carry most of the weight:

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

**Logic never lives in the widget tree.** A `build()` describes what a screen looks like; it does not
compute, validate, format or decide on the way past. Rules live in `domain/`, intent lives on a
`ChangeNotifier` controller owned by the screen's `State`, and the test for whether something is in
the right file is whether it can be unit-tested without pumping a widget.

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

Dependencies are attack surface, so the list is short and each entry is argued for in
[`CLAUDE.md`](CLAUDE.md): `cupertino_icons`, `flutter_secure_storage`, `video_player` and
`url_launcher`. Networking, state and DI stay hand-rolled in `core/`.

## The falcon

The bird in the loader, on the tab bar and on the rewards card is a glTF model — but nothing renders
it at runtime. Flutter has no glTF renderer, and every package offering one draws the model in a
WebView: a browser engine, an `INTERNET` permission and seconds of jank. So each clip is baked to a
numbered PNG sequence ahead of time and played back as frames.

```bash
node tool/render_model_frames.mjs <model.glb> assets/images/falcon/fly 24 320 Fly_Loop
```

The tool needs Node and `puppeteer`; the app needs neither. `FalconClip` in
`shared/widgets/falcon.dart` names the sequences and how each one is timed — re-run the tool when the
model changes, and nothing else moves.

## Testing

```bash
flutter analyze         # must be clean
flutter test            # 131 tests
dart format lib test
```

Tests mirror `lib/`. Reusable fakes live in `test/support/`. Everything is deterministic — the clock,
the transport and the random source are injected, and nothing sleeps.

## Project layout

```
lib/
  main.dart          entry point only: build deps, runApp
  app/               shell: DI, router, tab bar, theme tokens
  core/              config, errors, logging, network, security, utils
  features/          auth, onboarding, home, referrals, rewards,
                     community, notifications, profile, support
  shared/            domain models, formatting and share helpers, widgets
test/                mirrors lib/, plus support/ for fakes
tool/                render_model_frames.mjs — glTF clip to PNG sequence
assets/              fonts, images, falcon frame sequences, onboarding video
```

## Contributing

[`CLAUDE.md`](CLAUDE.md) holds the engineering rules this repo is built on — layering, widget and Dart
conventions, security requirements, rate-limit discipline, and the definition of done. Read it before
opening a PR; it is also the instruction file for Claude Code sessions in this project.
