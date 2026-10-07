import 'package:dart_mappable/dart_mappable.dart';

part 'base_stream_info.mapper.dart';

/// 流信息
@MappableClass(discriminatorKey: 'codec_type')
class BaseStreamInfo with BaseStreamInfoMappable {
  /// 索引
  final int index;

  /// 编码名称
  final String codecName;

  const BaseStreamInfo({required this.index, required this.codecName});
}
