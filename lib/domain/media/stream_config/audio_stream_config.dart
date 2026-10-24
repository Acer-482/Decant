import 'package:dart_mappable/dart_mappable.dart';
import 'package:decant/domain/encoder/audio_encoder.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';

part 'audio_stream_config.mapper.dart';

/// 音频流配置
@MappableClass(discriminatorValue: 'audio')
class AudioStreamConfig extends StreamConfig with AudioStreamConfigMappable {
  /// 编码器
  final AudioEncoder encoder;

  const AudioStreamConfig({
    required super.inputIndex,
    required super.streamIndex,
    super.copyMode,
    super.enabled,
    required this.encoder,
  });
}
