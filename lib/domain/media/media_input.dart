import 'package:decant/domain/media/media_info.dart';
import 'package:decant/domain/source/base_source.dart';

/// 输入媒体
///
/// 一个源，以及从它解析出来的媒体信息
/// UI 层用它把"源"和"探测结果"绑定在一起，避免两个列表各自按下标对齐
class MediaInput {
  /// 源
  final BaseSource source;

  /// 媒体信息
  final MediaInfo info;

  const MediaInput({required this.source, required this.info});
}
