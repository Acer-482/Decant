import 'package:dart_mappable/dart_mappable.dart';

part 'stream_config.mapper.dart';

/// 流配置
///
/// 单一流的配置
@MappableClass(discriminatorKey: 'type')
abstract class StreamConfig with StreamConfigMappable {
  /// 是否复制流
  final bool copyMode;

  /// 是否启用
  final bool enabled;

  const StreamConfig({this.copyMode = false, this.enabled = true});
}
