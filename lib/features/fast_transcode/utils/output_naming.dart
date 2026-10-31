import 'package:path/path.dart' as p;
import 'package:decant/domain/codec/audio_codec.dart';
import 'package:decant/domain/codec/video_codec.dart';
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';

/// 按编码推导容器后缀
///
/// 复制流沿用最常见的容器（mp4 / m4a），
/// 重新编码时按目标编码选更匹配的容器。
String extensionFor(List<StreamConfig> configs) {
  VideoStreamConfig? video;
  for (final config in configs) {
    if (config is VideoStreamConfig) {
      video = config;
      break;
    }
  }

  if (video != null) {
    if (video.copyMode) return 'mp4'; // 复制流：沿用最常见容器

    return switch (video.encoder.codec) {
      VideoCodec.h264 ||
      VideoCodec.hevc ||
      VideoCodec.av1 ||
      VideoCodec.mpeg4 ||
      VideoCodec.mpeg2 => 'mp4',
      VideoCodec.vp9 || VideoCodec.vp8 => 'webm',
      VideoCodec.prores || VideoCodec.dnxhd => 'mov',
      VideoCodec.ffv1 => 'mkv',
    };
  }

  AudioStreamConfig? audio;
  for (final config in configs) {
    if (config is AudioStreamConfig) {
      audio = config;
      break;
    }
  }

  if (audio != null) {
    if (audio.copyMode) return 'm4a'; // 复制流：aac 最常见

    return switch (audio.encoder.codec) {
      AudioCodec.aac => 'm4a',
      AudioCodec.mp3 => 'mp3',
      AudioCodec.opus => 'opus',
      AudioCodec.vorbis => 'ogg',
      AudioCodec.flac => 'flac',
      AudioCodec.alac => 'm4a',
      AudioCodec.ac3 => 'ac3',
      AudioCodec.eac3 => 'eac3',
      AudioCodec.dts => 'dts',
      AudioCodec.pcmS16le || AudioCodec.pcmS24le => 'wav',
    };
  }

  return 'mkv';
}

/// 补上后缀
///
/// 用户输入的文件名没有后缀时，按 [extension] 补一个
String ensureExtension(String name, String extension) {
  if (p.extension(name).isNotEmpty) return name;
  return '$name.$extension';
}
