# Contributing

Thanks for taking a look. Decant is in early alpha, so small and focused changes are much easier to review than large ones.

## Getting started

Requirements and platform notes live in [README › Build from source](README.md#build-from-source).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # *.mapper.dart is gitignored
flutter run -d windows
```

## Before pushing

```bash
dart format lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

- `dart format` is the only formatter — don't hand-align code.
- Generated mappers (`*.mapper.dart`) are ignored by git; never commit them.
- New logic should come with a test under `test/`, mirroring its path in `lib/`.

## Code style

- Comments are Chinese and short: a label, plus one line only when the intent isn't obvious.
- Prefer small widgets and pure functions. Keep `FfmpegArgsBuilder` free of UI and settings.
- Settings live behind `shared/services` plus one notifier per feature — pages never touch `SharedPreferences` directly.
- The transcode pipeline stays one-way: `MediaInfo → StreamConfig → FfmpegArgsBuilder → FFmpegKit`.

## Commits

Conventional Commits, English subject in the imperative mood, one idea per commit:

```
type(scope): short subject

- what changed and why, one bullet per point
```

Common scopes: `fast-transcode`, `settings`, `home`, `welcome`, `task-list`, `shared`, `ci`, `docs`, `release`.

- Keep the version bump in its own `chore(release): ...` commit — tags are placed on it.
- Don't amend or rewrite commits that are already pushed; add a `fix:` commit instead.

## Releases

Tags are cut from `main` and must match the `pubspec.yaml` version. The checklist and the artifact list are in [docs/RELEASING.md](docs/RELEASING.md).

## Documentation

- English is the primary language; [`docs/README_cn.md`](docs/README_cn.md) mirrors the README.
- Start from the [documentation index](docs/README.md).
