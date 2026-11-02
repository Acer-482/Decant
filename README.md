<div align="center">

**Language** · [**English**](README.md) / [**简体中文**](docs/README_cn.md)

</div>

# Decant

> Pour your media into any container.

**Decant** is a cross-platform media transcoder built on FFmpeg.

Drop a file in, take control of every stream the way FFmpeg lets you, and decide what happens to each one — remux losslessly, or re-encode with the encoder you choose.

The name comes from decanting wine: pouring it from one vessel into another, and deciding what to leave behind.

## Status

Early alpha, under active development. Things will break and the UI will change — if you run into a problem, please open an issue.

| Platform | State |
| --- | --- |
| Windows | Built and tested — the primary target |
| Linux | Buildable from source; the CI build is not green yet |
| macOS | Buildable from source; the CI build is not green yet |
| Android | Debug APK built by CI; not yet verified by hand |
| iOS | Unsigned build by CI; archive only, it cannot be installed |
| Web | Not supported — FFmpegKit has no web backend |

## What works today

- Drag & drop, or pick local media files
- **Multiple inputs** — merge the streams of several files into one output
- Inspect every stream with `ffprobe`: codec, resolution, frame rate, sample rate, channels, bitrate. File details are one click away, both on the picker and on the settings step
- Per-stream configuration:
  - enable / disable a stream
  - **copy** the stream (lossless remux) or re-encode it
  - pick the encoder — H.264 / HEVC / AV1 / VP9 / ProRes / DNxHD / FFV1 / MPEG-4 … including hardware encoders, and the audio equivalents
  - send a stream to its own file, with its own path
- Output: choose the directory, rename the main file — the container is derived from the codec you picked
- Run the transcode with live progress, and **cancel** it mid-run
- Success / failure / cancelled screens: the full FFmpeg log on error, retry, or go back to the settings with your per-stream choices intact
- Writes to a `.part` file first, so an interrupted run never leaves something that looks like a finished file
- Settings page: theme mode and accent colour, default output directory, auto-open the output folder when done, and a reset for all of it

## Not there yet

- The task list lives in memory only — it does not survive a restart, and is not wired to real jobs
- UI is Chinese-only
- No presets ("simple mode") — that's the next milestone
- No image transcoding
- One job at a time; there is no batch queue
- No installers or code signing — releases are plain archives
- Hardware encoders can be picked per stream, but there is no "prefer hardware" default

## Build from source

Requirements:

- Flutter SDK with Dart `^3.13.5`
- Windows: Visual Studio 2022 with the **Desktop development with C++** workload
- Linux: `clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libjson-glib-dev`
- macOS / iOS: Xcode with Swift Package Manager (both projects use SPM, not CocoaPods)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerate mappers
flutter run -d windows
```

Tests:

```bash
flutter test
```

Release build:

```bash
flutter build windows --release
```

The executable is written to `build/windows/x64/runner/Release/`.

Tag-driven releases are built by GitHub Actions — see [docs/RELEASING.md](docs/RELEASING.md) for the artifacts and the release checklist.

## How it's put together

```
lib/
  domain/     pure models: media info, stream info/config, encoders, tasks
  features/   UI + state, split by feature (fast_transcode, settings, task_list, welcome, home)
  shared/     widgets, formatters, the preferences service and app constants
  devtools/   scratch pages for poking at FFmpeg directly
```

The pipeline is intentionally one-way:

```
media file → MediaInfo (ffprobe) → List<StreamConfig> → FfmpegArgsBuilder → FFmpegKit
```

Preferences sit beside it rather than inside it: the pipeline stays pure, and the pages read the settings to pick defaults (output directory, theme, auto-open).

## Roadmap

- [ ] Presets ("send it to WeChat", "archive", "editing proxy")
- [ ] Image transcoding
- [ ] Finish the task list; a real batch queue
- [ ] i18n
- [ ] A "prefer hardware encoding" default
- [ ] Installers and code signing

## License

[GPL-3.0](LICENSE).
