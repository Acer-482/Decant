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
| Windows | Built and tested |
| Linux / macOS | Project scaffolding exists, not yet verified |
| iOS / Android | Project scaffolding exists, not yet verified |
| Web | Not supported |

## What works today

- Drag & drop, or pick a local media file
- Inspect the file with `ffprobe`: duration, bitrate, container, and every stream (codec, resolution, frame rate, sample rate, channels)
- Per-stream configuration:
  - enable / disable a stream
  - **copy** the stream (lossless remux) or re-encode it
  - pick the encoder — H.264 / HEVC / AV1 / VP9 / ProRes … and the audio equivalents
- Run the transcode with live progress, parsed from FFmpeg's statistics callback
- Success / failure screen with the full FFmpeg log on error, plus retry and "open output folder"

## Not there yet

- Output container is fixed to `.mp4`
- A running transcode cannot be cancelled
- The task list lives in memory only — it does not survive a restart, and is not wired to real jobs
- UI is Chinese-only
- No test suite
- No presets (a "simple mode") — that's the next milestone

## Build from source

Requirements:

- Flutter SDK with Dart `^3.13.5`
- Windows: Visual Studio 2022 with the **Desktop development with C++** workload
- Linux: `clang cmake ninja-build pkg-config libgtk-3-dev`

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerate mappers
flutter run -d windows
```

Release build:

```bash
flutter build windows --release
```

The executable is written to `build/windows/x64/runner/Release/`.

## How it's put together

```
lib/
  domain/     pure models: media info, stream info/config, encoders, tasks
  features/   UI + state, split by feature (fast_transcode, task_list, …)
  shared/     small widgets and formatting helpers
  devtools/   scratch pages for poking at FFmpeg directly
```

The pipeline is intentionally one-way:

```
media file → MediaInfo (ffprobe) → List<StreamConfig> → FfmpegArgsBuilder → FFmpegKit
```

## Roadmap

- [ ] Cancel / pause a running job
- [ ] Presets ("send it to WeChat", "archive", "editing proxy")
- [ ] Image transcoding
- [ ] Multiple files, concurrent stream processing
- [ ] Finish the task list; a real batch queue
- [ ] i18n

## License

[GPL-3.0](LICENSE).
