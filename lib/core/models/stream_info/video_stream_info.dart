import 'package:dart_mappable/dart_mappable.dart';

import 'base_stream_info.dart';

part 'video_stream_info.mapper.dart';

/// 视频流信息
@MappableClass(discriminatorValue: 'video')
class VideoStreamInfo extends BaseStreamInfo with VideoStreamInfoMappable {
  /// 宽高
  final int width, height;

  final String pixFmt;

  const VideoStreamInfo({
    required super.index,
    required super.codecName,
    required this.width,
    required this.height,
    required this.pixFmt,
  });
}
