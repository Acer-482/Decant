import 'package:decant/domain/media/stream_info/base_stream_info.dart';

/// 媒体信息
///
/// 领域模型
class MediaInfo {
  /// 时长
  final String duration;

  /// 大小
  final String size;

  /// 码率
  final String bitrate;

  /// 数据流
  final List<BaseStreamInfo> streams;

  const MediaInfo({
    required this.duration,
    required this.size,
    required this.bitrate,
    required this.streams,
  });
}
