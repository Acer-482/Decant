import 'package:dart_mappable/dart_mappable.dart';
import 'package:decant/domain/encoder/video_encoder.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';

part 'video_stream_config.mapper.dart';

/// 视频流配置
@MappableClass(discriminatorValue: 'video')
class VideoStreamConfig extends StreamConfig with VideoStreamConfigMappable {
  /// 编码器
  final VideoEncoder encoder;

  const VideoStreamConfig({
    required super.inputIndex,
    required super.streamIndex,
    super.copyMode,
    super.enabled,
    required this.encoder,
  });
}
