import 'package:dart_mappable/dart_mappable.dart';
import 'package:media_transcoder/domain/media/stream_info/base_stream_info.dart';

part 'unknow_stream_info.mapper.dart';

/// 未知流信息
@MappableClass(discriminatorValue: MappableClass.useAsDefault)
final class UnknownStreamInfo extends BaseStreamInfo
    with UnknownStreamInfoMappable {
  /// 编码类型
  final String codecType;

  const UnknownStreamInfo({
    required super.index,
    required super.codecName,
    required this.codecType,
  });
}
