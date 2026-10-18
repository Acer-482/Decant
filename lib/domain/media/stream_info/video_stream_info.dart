import 'package:dart_mappable/dart_mappable.dart';

import 'base_stream_info.dart';

part 'video_stream_info.mapper.dart';

/// 视频流信息
@MappableClass(discriminatorValue: 'video')
class VideoStreamInfo extends BaseStreamInfo with VideoStreamInfoMappable {
  /// 宽高
  final int width, height;

  /// 像素格式
  final String pixFmt;

  /// 码率 (bps)
  final String? bitRate;

  /// 帧率
  final String? frameRate;

  /// 色彩空间
  final String? colorSpace;

  /// 色彩范围
  final String? colorRange;

  /// 配置 (例如 "High", "Main")
  final String? profile;
  const VideoStreamInfo({
    required super.index,
    required super.codecName,
    required this.width,
    required this.height,
    required this.pixFmt,
    this.bitRate,
    this.frameRate,
    this.colorSpace,
    this.colorRange,
    this.profile,
  });
}
