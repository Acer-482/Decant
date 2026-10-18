import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/domain/media/media_info.dart';
import 'package:media_transcoder/domain/media/stream_info/audio_stream_info.dart';
import 'package:media_transcoder/domain/media/stream_info/unknown_stream_info.dart';
import 'package:media_transcoder/domain/media/stream_info/video_stream_info.dart';

/// 媒体信息提供器
///
/// 按文件路径解析媒体信息
///
/// 同一个 path 多次 watch 只请求一次。
/// 页面销毁或不再使用时自动释放。

final mediaInfoProvider = FutureProvider.autoDispose.family<MediaInfo, String>((
  ref,
  path,
) async {
  final session = await FFprobeKit.getMediaInformation(path); // 获取媒体信息

  final rc = await session.getReturnCode(); // 获取返回码
  if (rc == null) throw Exception('无返回值');
  if (!rc.isValueSuccess()) throw Exception('非媒体文件或解析失败');

  final info = session.getMediaInformation(); // 获取媒体数据
  if (info == null) throw Exception('解析失败');

  // 解析流信息 //
  final streams = info.getStreams().map((s) {
    final index = s.getIndex() ?? 0; // 流索引
    final codecName = s.getCodec() ?? 'unknown'; // 编码名称
    final type = s.getType(); // 类型

    // 视频流
    if (type == 'video') {
      return VideoStreamInfo(
        index: index,
        codecName: codecName,
        width: s.getWidth() ?? 0,
        height: s.getHeight() ?? 0,
        pixFmt: s.getFormat() ?? 'unknown',
        bitRate: s.getBitrate(),
        frameRate: s.getRealFrameRate(),
        colorSpace: s.getStringProperty('color_space'),
        colorRange: s.getStringProperty('color_range'),
        profile: s.getStringProperty('profile'),
      );
    } else // 音频流
    if (type == 'audio') {
      return AudioStreamInfo(
        index: index,
        codecName: codecName,
        sampleRate: int.tryParse(s.getSampleRate() ?? '') ?? 0,
        channels: s.getNumberProperty('channels')?.toInt() ?? 0,
        channelLayout: s.getChannelLayout(),
        bitRate: s.getBitrate(),
      );
    } else // 未知流
    {
      return UnknownStreamInfo(
        index: index,
        codecName: codecName,
        codecType: type ?? 'unknown',
      );
    }
  }).toList();

  return MediaInfo(
    duration: info.getDuration() ?? '0',
    size: info.getSize() ?? '0',
    bitrate: info.getBitrate() ?? '0',
    streams: streams,
  );
});
