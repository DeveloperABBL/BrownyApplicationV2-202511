# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Browny Application V3 — Flutter app for laundry service management. Targets Android and iOS (Web planned). Package name: `browny_applications_new`. Current version: `3.0.3+63`. Dart SDK `>=3.10.0 <4.0.0`.

## Commonly Used Commands

```bash
flutter pub get                                          # install deps
flutter run                                              # run on connected device
dart run build_runner build --delete-conflicting-outputs # regen Retrofit/JSON/Hive after model changes
flutter gen-l10n                                         # regen ARB localizations
flutter analyze                                          # lint (uses analysis_options.yaml + flutter_lints)
flutter test                                             # run all tests
flutter test test/path/to/file_test.dart                 # run a single test file
flutter test --name "<test name>"                        # run single test by name
flutter build apk --release
flutter build ios --release
```

Code generation is required after editing any file with `@JsonSerializable`, `@RestApi`, or Hive `@HiveType` annotations — generated outputs (`*.g.dart`, `*.freezed.dart`) live next to source.

## Architecture

Clean Architecture + MVVM with **Provider** (`ChangeNotifier`) for state. Single Retrofit/Dio HTTP client, Hive (community edition `hive_ce`) for local storage, `go_router` for navigation, `flutter_screenutil` for responsive sizing.

### Layout

```
lib/
├── main.dart                  # Firebase init → AppEnvironment.loadEnv() → NotificationHelper → runApp
├── core/
│   ├── env/                   # AppEnvironment (abstract), DevEnvironment, PrdEnvironment — load env/{dev,prd}.json
│   ├── client/                # Dio/Retrofit setup
│   ├── data/{cache,remote,repo}/   # Hive cache, Retrofit AppClient, AppRepository base
│   ├── services/live_activity/     # iOS Live Activities bridge
│   ├── utils/                 # CrashlyticsHelper, NotificationHelper (FCM + flutter_local_notifications), etc.
│   ├── providers/             # shared ChangeNotifier providers
│   ├── viewmodels/            # AppViewModel (root)
│   └── widgets/               # shared UI
├── feature/<name>/            # one folder per feature: models/, repository/, viewmodel/, screens/ or view/, widgets/
│   e.g. authentication, home, transactions, wallet, coin, profile,
│        articles, contacts, invit_friend, lucky_scan, map, onboarding,
│        scaner, update
└── res/                       # generated localizations, colors, theme, icons (flutter_gen output)
```

`flutter_gen.output` is `lib/res/icons` (NOT the default `lib/gen/`).

### Data Flow

`View → ViewModel (ChangeNotifier) → Repository → AppClient (Retrofit/Dio) | AppLocalStorage (Hive)`

Each feature repository extends `AppRepository` (in `lib/core/data/repo/`) so it shares the configured `AppClient` + `AppLocalStorage`. All API responses extend `BaseModelResponse` (`success`, `message`, `errorType`).

### Environment

- Env JSON files live in `env/dev.json` and `env/prd.json` (loaded at runtime by `AppEnvironment.loadEnv()`).
- `main.dart` currently hard-codes `DevEnvironment()` — switch to `PrdEnvironment()` for production builds.
- Firebase config via `firebase_options.dart` (FlutterFire CLI generated).

### Localization

ARB files: `lib/res/strings/l10n/app_{en,th,zh}.arb` → generated `AppLocalizations`. Three locales: Thai (default), English, Chinese. Default language stored in Hive via `AppLocalStorage.getLanguage()` (falls back to `'th'`).

## Conventions & Gotchas

- **State belongs in the ViewModel — `setState` is a last resort, not a shortcut.** This project is strict MVVM with Provider. Any data the view renders (API results, derived flags, page state) must live in the feature's `ViewModel` and be exposed as `ValueListenable<T>` (default) or via the ViewModel's own `notifyListeners()` if a `Consumer` is already in place. The View `subscribe`s via `ValueListenableBuilder` / `Consumer`. **Do NOT** cache server responses in a `StatefulWidget`'s `State`, do NOT call `setState` to drive a `FutureBuilder.future = vm.fetch()`, do NOT store sorted/derived versions of VM data inside `State` — that bypasses MVVM, leaks state out of the layer that owns it, and produces side-effect bugs (e.g. `MediaQuery` rebuilds re-firing API calls). `setState` is acceptable ONLY for truly local, ephemeral UI flags inside small widgets — expand/collapse, swipe offset, currently-focused index — never for anything sourced from a repo/API/VM. Before reaching for `setState`, look at how sibling notifiers in the same VM are wired and follow that pattern.
- **Generator compatibility**: `retrofit_generator: ^10.2.5` and `hive_ce_generator: ^1.11.1` were chosen to coexist — do not bump independently without verifying both still build.
- Use `hive_ce` / `hive_ce_flutter` (community edition). Do **not** add the original `hive` package.
- Adding a new feature: create `lib/feature/<name>/{models,repository,viewmodel,screens,widgets}/`. The repository should extend `AppRepository`; expose the viewmodel via Provider in `main.dart` or the relevant subtree.
- Adding new asset folders requires registering them under `flutter.assets` in `pubspec.yaml`.
- iOS app icons are managed via `icon_launcher.yaml` (`icons_launcher` package) — regenerate rather than hand-editing the `Assets.xcassets` PNGs.
- Native splash via `flutter_native_splash.yaml`.
- App auto-update prompts use the `upgrader` package; minimum supported versions are driven by remote env config, not pubspec.

## Commit Style

Commit messages in this repo are written in Thai, often as bulleted release notes (see `git log`). Match that style when committing on behalf of the user.
