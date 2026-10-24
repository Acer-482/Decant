import 'package:dart_mappable/dart_mappable.dart';

part 'stream_config.mapper.dart';

/// 流配置
///
/// 指向某一路输入中的某一条流，并描述这条流该如何输出
///
/// 自带 [inputIndex] 与 [streamIndex]，所以配置列表与流列表**不需要按顺序对齐**
/// 支持多路输入，例如合并两个文件
@MappableClass(discriminatorKey: 'type')
abstract class StreamConfig with StreamConfigMappable {
  /// 输入序号，对应 sources 的下标
  final int inputIndex;

  /// 流在该输入中的序号
  final int streamIndex;

  /// 是否复制流
  final bool copyMode;

  /// 是否启用
  final bool enabled;

  const StreamConfig({
    required this.inputIndex,
    required this.streamIndex,
    this.copyMode = true,
    this.enabled = true,
  });

  /// FFmpeg 的流标识，例如 `0:1` 表示第 0 路输入的第 1 条流
  String get mapTarget => '$inputIndex:$streamIndex';
}
