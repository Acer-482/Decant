import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/media_information.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 媒体信息提供器
///
/// 按文件路径解析媒体信息
///
/// 同一个 path 多次 watch 只请求一次。
/// 页面销毁或不再使用时自动释放。
final mediaInfoProvider = FutureProvider.autoDispose
    .family<MediaInformation, String>((ref, path) async {
      final session = await FFprobeKit.getMediaInformation(path);
      final rc = await session.getReturnCode();

      if (rc == null) throw Exception('无返回值');
      if (!rc.isValueSuccess()) {
        throw Exception('非媒体文件或解析失败');
      }
      final info = session.getMediaInformation();
      if (info == null) throw Exception('解析失败');
      return info;
    });
