import 'package:dart_mappable/dart_mappable.dart';
import 'package:media_transcoder/domain/encoder/video_encoder.dart';
import 'package:media_transcoder/domain/media/stream_config/stream_config.dart';

part 'video_stream_config.mapper.dart';

/// 媒体流配置
@MappableClass(discriminatorValue: 'VideoStreamConfig')
abstract class VideoStreamConfig extends StreamConfig
    with VideoStreamConfigMappable {
  /// 编码器
  final VideoEncoder encoder;

  const VideoStreamConfig({
    super.copyMode,
    super.enabled,
    required this.encoder,
  });
}
