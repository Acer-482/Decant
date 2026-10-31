import 'package:decant/domain/codec/audio_codec.dart';
import 'package:decant/domain/codec/video_codec.dart';
import 'package:decant/domain/media/media_info.dart';
import 'package:decant/domain/media/stream_info/audio_stream_info.dart';
import 'package:decant/domain/media/stream_info/base_stream_info.dart';
import 'package:decant/domain/media/stream_info/video_stream_info.dart';
import 'package:decant/shared/utils/media_format_utils.dart';

/// 流的标题
String streamTitle(BaseStreamInfo stream) {
  if (stream is VideoStreamInfo) return '视频流 #${stream.index}';
  if (stream is AudioStreamInfo) return '音频流 #${stream.index}';
  return '未知流 #${stream.index}';
}

/// 流的编码信息
///
/// 视频：`H.264 · 1920×1080 · 25 fps`
/// 音频：`AAC · 44.1 kHz`
String codecInfo(BaseStreamInfo stream) {
  final name = codecName(stream.codecName);

  if (stream is VideoStreamInfo) {
    return [
      name,
      if (stream.width > 0) '${stream.width}×${stream.height}',
      if (stream.frameRate != null)
        MediaFormatUtils.frameRate(stream.frameRate),
    ].join(' · ');
  }

  if (stream is AudioStreamInfo) {
    return [
      name,
      if (stream.sampleRate > 0)
        MediaFormatUtils.sampleRate(stream.sampleRate.toString()),
    ].join(' · ');
  }

  return name;
}

/// 媒体摘要
String mediaSummary(MediaInfo info) {
  VideoStreamInfo? video;
  for (final stream in info.streams) {
    if (stream is VideoStreamInfo) {
      video = stream;
      break;
    }
  }

  return [
    MediaFormatUtils.duration(info.duration),
    if (video != null) '${video.width}×${video.height}',
    '${info.streams.length} 条流',
  ].join(' · ');
}

/// 编码显示名
String codecName(String ffprobeName) {
  for (final codec in VideoCodec.values) {
    if (codec.ffprobeName == ffprobeName) return codec.displayName;
  }
  for (final codec in AudioCodec.values) {
    if (codec.ffprobeName == ffprobeName) return codec.displayName;
  }
  return ffprobeName.toUpperCase();
}
