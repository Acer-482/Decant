import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/media/stream_config/unknown_stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/domain/source/base_source.dart';

/// FFmpeg 参数构建
class FfmpegArgsBuilder {
  FfmpegArgsBuilder._();

  /// 把流配置翻译成 `-map` / `-c:*` 参数
  ///
  /// 每条启用的配置自带 `输入序号:流序号`，因此多路输入不需要调用方
  /// 维护"配置列表与流列表顺序对齐"这条隐含约定。
  static List<String> build(List<StreamConfig> configs) {
    final args = <String>[];

    for (final config in configs) {
      if (!config.enabled) continue; // 禁用的流不产生任何参数

      args.addAll(['-map', config.mapTarget]);

      switch (config) {
        case final VideoStreamConfig video:
          args.addAll([
            '-c:v',
            video.copyMode ? 'copy' : video.encoder.ffmpegName,
          ]);
        case final AudioStreamConfig audio:
          args.addAll([
            '-c:a',
            audio.copyMode ? 'copy' : audio.encoder.ffmpegName,
          ]);
        case final UnknownStreamConfig unknown:
          // 未知流没有区分 v/a/s，只能整体 copy
          if (unknown.copyMode) args.addAll(['-c', 'copy']);
      }
    }

    return args;
  }

  /// 组装完整的 FFmpeg 命令
  ///
  /// 形如：`-y -i "a.mp4" -i "b.mkv" -map 0:0 -c:v copy -map 1:1 -c:a aac "out.mp4"`
  static String buildCommand({
    required List<BaseSource> sources,
    required List<StreamConfig> configs,
    required String outputPath,
  }) {
    final buffer = StringBuffer('-y');
    for (final source in sources) {
      buffer.write(' -i ${_quote(source.input)}');
    }

    final args = build(configs);
    if (args.isNotEmpty) buffer.write(' ${args.join(' ')}');

    buffer.write(' ${_quote(outputPath)}');
    return buffer.toString();
  }

  /// 为路径加上引号并转义，避免空格、中文、引号破坏命令
  static String _quote(String value) {
    final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    return '"$escaped"';
  }
}
