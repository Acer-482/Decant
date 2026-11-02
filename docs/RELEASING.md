# Releasing

Releases are built by [`.github/workflows/release.yml`](../.github/workflows/release.yml) and triggered by tags that start with `v`.

## Versioning

`pubspec.yaml` holds the version as `MAJOR.MINOR.PATCH+BUILD` (e.g. `0.2.0+1`). The build number becomes Android's `versionCode`.

The tag must match the pubspec version exactly — the `prepare` job fails the run otherwise:

```
version: 0.2.0+1   →   tag v0.2.0
```

A version with a pre-release suffix (`0.3.0-beta.1`) produces a pre-release on GitHub.

## Cutting a release

1. Bump `version:` in `pubspec.yaml`.
2. Commit and push to `main`.
3. Tag and push the tag:

```bash
git tag v0.2.0
git push origin v0.2.0
```

CI runs the tests first, then builds every platform in parallel, and finally publishes a GitHub Release with the artifacts plus a `SHA256SUMS.txt`.

## What gets built

| Platform | Artifact | Notes |
| --- | --- | --- |
| Windows | `decant-<version>-windows-x64.zip` | unpack and run `decant.exe` |
| Linux | `decant-<version>-linux-x64.tar.gz` | `tar -xzf`, run `bundle/decant` |
| macOS | `decant-<version>-macos-arm64.zip` | unsigned `Decant.app`, runner is arm64 |
| iOS | `decant-<version>-ios-unsigned.zip` | unsigned `Runner.app`; archive only, it cannot be installed |
| Android | `decant-<version>-android-debug.apk` | debug signing until a keystore exists |

Web is not built: FFmpegKit has no web backend.

## Dry run

`Actions → Release → Run workflow` builds everything without creating a Release — use it to validate the workflow before tagging.

## Notes

- `pubspec.lock` records the `pub.flutter-io.cn` mirror; the setup action rewrites it to `pub.dev` inside the runner so the build does not depend on the mirror. The committed lock file is untouched.
- The Flutter version is pinned in `.github/actions/setup-flutter/action.yml`. Keep it in sync with local development.
- Mapper files (`*.mapper.dart`) are gitignored, so the setup action runs `build_runner` before every build.
