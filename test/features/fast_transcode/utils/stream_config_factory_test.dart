import 'package:flutter_test/flutter_test.dart';
import 'package:decant/domain/encoder/audio_encoder.dart';
import 'package:decant/domain/encoder/encoder_type.dart';
import 'package:decant/domain/encoder/video_encoder.dart';
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/unknown_stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/domain/media/stream_info/audio_stream_info.dart';
import 'package:decant/domain/media/stream_info/unknown_stream_info.dart';
import 'package:decant/domain/media/stream_info/video_stream_info.dart';
import 'package:decant/features/fast_transcode/utils/stream_config_factory.dart';

VideoStreamInfo _video(String codecName) => VideoStreamInfo(
  index: 0,
  codecName: codecName,
  width: 1920,
  height: 1080,
  pixFmt: 'yuv420p',
);

AudioStreamInfo _audio(String codecName) => AudioStreamInfo(
  index: 1,
  codecName: codecName,
  sampleRate: 48000,
  channels: 2,
);

void main() {
  group('视频流', () {
    test('按源编码选同名软件编码器', () {
      final config = defaultStreamConfig(_video('h264'), 2);

      expect(config, isA<VideoStreamConfig>());
      expect((config as VideoStreamConfig).encoder, VideoEncoder.libx264);
      expect(config.inputIndex, 2);
      expect(config.streamIndex, 0);
      expect(config.encoder.type, EncoderType.software);
    });

    test('HEVC 选 libx265', () {
      final config = defaultStreamConfig(_video('hevc'), 0) as VideoStreamConfig;

      expect(config.encoder, VideoEncoder.libx265);
    });

    test('不认识的编码兜底 libx264', () {
      final config = defaultStreamConfig(_video('weird'), 0) as VideoStreamConfig;

      expect(config.encoder, VideoEncoder.libx264);
    });
  });

  group('音频流', () {
    test('按源编码选同名编码器', () {
      final config = defaultStreamConfig(_audio('aac'), 1);

      expect(config, isA<AudioStreamConfig>());
      expect((config as AudioStreamConfig).encoder, AudioEncoder.aac);
      expect(config.inputIndex, 1);
      expect(config.streamIndex, 1);
    });

    test('mp3 选 libmp3lame', () {
      final config = defaultStreamConfig(_audio('mp3'), 0) as AudioStreamConfig;

      expect(config.encoder, AudioEncoder.libmp3lame);
    });

    test('不认识的编码兜底 aac', () {
      final config = defaultStreamConfig(_audio('weird'), 0) as AudioStreamConfig;

      expect(config.encoder, AudioEncoder.aac);
    });
  });

  test('未知流默认禁用且复制', () {
    final config = defaultStreamConfig(
      UnknownStreamInfo(index: 2, codecName: 'hdmv_pgs', codecType: 'subtitle'),
      0,
    );

    expect(config, isA<UnknownStreamConfig>());
    expect(config.enabled, isFalse);
    expect(config.copyMode, isTrue);
    expect(config.streamIndex, 2);
  });
}
