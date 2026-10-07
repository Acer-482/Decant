import 'package:dart_mappable/dart_mappable.dart';
import 'package:media_transcoder/core/models/stream_info/base_stream_info.dart';

part 'audio_stream_info.mapper.dart';

/// 音频流信息
@MappableClass()
class AudioStreamInfo extends BaseStreamInfo with AudioStreamInfoMappable {
  /// 采样率
  final int sampleRate;

  /// 通道
  final int channels;

  const AudioStreamInfo({
    required super.index,
    required super.codecName,
    required this.sampleRate,
    required this.channels,
  });
}
