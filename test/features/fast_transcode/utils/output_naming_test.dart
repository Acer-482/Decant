import 'package:flutter_test/flutter_test.dart';
import 'package:decant/domain/encoder/audio_encoder.dart';
import 'package:decant/domain/encoder/video_encoder.dart';
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/features/fast_transcode/utils/output_naming.dart';

VideoStreamConfig _video(
  VideoEncoder encoder, {
  bool copy = false,
}) => VideoStreamConfig(
  inputIndex: 0,
  streamIndex: 0,
  copyMode: copy,
  encoder: encoder,
);

AudioStreamConfig _audio(
  AudioEncoder encoder, {
  bool copy = false,
}) => AudioStreamConfig(
  inputIndex: 0,
  streamIndex: 1,
  copyMode: copy,
  encoder: encoder,
);

void main() {
  group('extensionFor 视频', () {
    const mp4 = [
      VideoEncoder.libx264,
      VideoEncoder.libx265,
      VideoEncoder.libsvtav1,
      VideoEncoder.mpeg4,
      VideoEncoder.mpeg2video,
    ];
    const webm = [VideoEncoder.libvpxVp9, VideoEncoder.libvpx];
    const mov = [VideoEncoder.proresKs, VideoEncoder.dnxhd];
    const mkv = [VideoEncoder.ffv1];

    for (final encoder in mp4) {
      test('${encoder.ffmpegName} 用 mp4', () {
        expect(extensionFor([_video(encoder)]), 'mp4');
      });
    }

    for (final encoder in webm) {
      test('${encoder.ffmpegName} 用 webm', () {
        expect(extensionFor([_video(encoder)]), 'webm');
      });
    }

    for (final encoder in mov) {
      test('${encoder.ffmpegName} 用 mov', () {
        expect(extensionFor([_video(encoder)]), 'mov');
      });
    }

    for (final encoder in mkv) {
      test('${encoder.ffmpegName} 用 mkv', () {
        expect(extensionFor([_video(encoder)]), 'mkv');
      });
    }

    test('复制视频流沿用 mp4', () {
      expect(extensionFor([_video(VideoEncoder.libvpx, copy: true)]), 'mp4');
    });
  });

  group('extensionFor 音频', () {
    const cases = {
      AudioEncoder.aac: 'm4a',
      AudioEncoder.libfdkAac: 'm4a',
      AudioEncoder.libmp3lame: 'mp3',
      AudioEncoder.libopus: 'opus',
      AudioEncoder.libvorbis: 'ogg',
      AudioEncoder.flac: 'flac',
      AudioEncoder.alac: 'm4a',
      AudioEncoder.ac3: 'ac3',
      AudioEncoder.eac3: 'eac3',
      AudioEncoder.pcmS16le: 'wav',
      AudioEncoder.pcmS24le: 'wav',
    };

    cases.forEach((encoder, expected) {
      test('${encoder.ffmpegName} 用 $expected', () {
        expect(extensionFor([_audio(encoder)]), expected);
      });
    });

    test('复制音频流沿用 m4a', () {
      expect(extensionFor([_audio(AudioEncoder.libvorbis, copy: true)]), 'm4a');
    });
  });

  test('同时有视频与音频时以视频为准', () {
    final configs = [
      _video(VideoEncoder.libvpxVp9),
      _audio(AudioEncoder.libmp3lame),
    ];

    expect(extensionFor(configs), 'webm');
  });

  test('没有任何流时退回 mkv', () {
    expect(extensionFor([]), 'mkv');
  });

  group('ensureExtension', () {
    test('没有后缀时补上', () {
      expect(ensureExtension('结局', 'mp4'), '结局.mp4');
    });

    test('已有后缀时保持原样', () {
      expect(ensureExtension('结局.mkv', 'mp4'), '结局.mkv');
    });

    test('多段后缀只认最后一段', () {
      expect(ensureExtension('archive.tar.gz', 'mp4'), 'archive.tar.gz');
    });
  });
}
