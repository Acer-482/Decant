import 'package:dart_mappable/dart_mappable.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';

part 'unknown_stream_config.mapper.dart';

/// 未知流配置（占位用）
@MappableClass(discriminatorValue: 'unknown')
class UnknownStreamConfig extends StreamConfig
    with UnknownStreamConfigMappable {
  const UnknownStreamConfig({
    required super.inputIndex,
    required super.streamIndex,
    super.copyMode,
    super.enabled = false, // 未知流默认禁用
  });
}
