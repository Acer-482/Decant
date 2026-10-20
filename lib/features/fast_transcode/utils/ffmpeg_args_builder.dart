import 'package:media_transcoder/domain/media/stream_config/audio_stream_config.dart';
import 'package:media_transcoder/domain/media/stream_config/stream_config.dart';
import 'package:media_transcoder/domain/media/stream_config/video_stream_config.dart';
import 'package:media_transcoder/domain/media/stream_info/base_stream_info.dart';

class FfmpegArgsBuilder {
  FfmpegArgsBuilder._();

  /// 解释流配置到 FFmpeg 命令行参数
  static List<String> build(
    List<StreamConfig> configs,
    List<BaseStreamInfo> streams,
  ) {
    final args = <String>[];

    for (int i = 0; i < configs.length; i++) {
      final config = configs[i];

      if (!config.enabled) continue; // 如果流被禁用时直接跳过，不生成任何 map 和 codec 参数

      final stream = streams[i];
      args.addAll(['-map', '0:${stream.index}']); // 映射当前流 (0:${stream.index})

      if (config is VideoStreamConfig) {
        if (config.copyMode) {
          args.addAll(['-c:v', 'copy']);
        } else {
          args.addAll(['-c:v', config.encoder.ffmpegName]);
        }
      } else if (config is AudioStreamConfig) {
        if (config.copyMode) {
          args.addAll(['-c:a', 'copy']);
        } else {
          args.addAll(['-c:a', config.encoder.ffmpegName]);
        }
      } else if (config.copyMode) {
        // 未知流如果被启用且要求复制，默认加上 copy
        // 但由于未知流没有区分 v/a/s，稳妥起见这里不写特定流类型的 codec
      }
    }

    return args;
  }
}
