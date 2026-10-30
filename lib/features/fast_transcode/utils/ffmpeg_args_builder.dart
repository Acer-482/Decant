import 'package:path/path.dart' as p;
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/media/stream_config/unknown_stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/domain/source/base_source.dart';

/// 一个输出文件
class FfmpegOutput {
  /// 文件路径
  final String path;

  /// 是否为主输出
  final bool main;

  const FfmpegOutput(this.path, {this.main = false});
}

/// 一条完整的 FFmpeg 命令
class FfmpegCommand {
  /// 命令字符串
  final String command;

  /// 会产出的文件
  final List<FfmpegOutput> outputs;

  const FfmpegCommand(this.command, this.outputs);
}

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

  /// 单条独立输出的路径
  ///
  /// 有自定义路径时直接用，否则按输出目录 + 默认命名
  static String outputPathFor(
    StreamConfig config, {
    required String outputDir,
    required String baseName,
  }) {
    final custom = config.outputPath;
    if (custom != null && custom.isNotEmpty) return custom;

    if (config is VideoStreamConfig) {
      return p.join(outputDir, '${baseName}_video.mp4');
    }
    if (config is AudioStreamConfig) {
      return p.join(outputDir, '${baseName}_audio.${_audioExtension(config)}');
    }
    return p.join(outputDir, '${baseName}_stream${config.streamIndex}.mkv');
  }

  /// 组装完整的 FFmpeg 命令
  ///
  /// 勾选「单独输出」的流按最终路径分组：路径相同的流会写进同一个文件，
  /// 路径不同的各写各的，一条命令里用多个 `-map ... <path>` 完成。
  static FfmpegCommand buildCommand({
    required List<BaseSource> sources,
    required List<StreamConfig> configs,
    required String outputDir,
    required String baseName,
  }) {
    final enabled = configs.where((config) => config.enabled).toList();

    final mainConfigs = enabled
        .where((config) => !config.separateOutput)
        .toList();

    final groups = <String, List<StreamConfig>>{};
    for (final config in enabled.where((c) => c.separateOutput)) {
      final path = outputPathFor(
        config,
        outputDir: outputDir,
        baseName: baseName,
      );
      groups.putIfAbsent(path, () => []).add(config);
    }

    final outputs = <FfmpegOutput>[];
    final buffer = StringBuffer('-y');

    for (final source in sources) {
      buffer.write(' -i ${_quote(source.input)}');
    }

    void addOutput(List<StreamConfig> group, String path) {
      if (group.isEmpty) return;

      buffer.write(' ${build(group).join(' ')} ${_quote(path)}');
      outputs.add(FfmpegOutput(path, main: outputs.isEmpty));
    }

    addOutput(mainConfigs, p.join(outputDir, '$baseName.mp4'));
    for (final entry in groups.entries) {
      addOutput(entry.value, entry.key);
    }

    return FfmpegCommand(buffer.toString(), outputs);
  }

  /// 音频单独输出时的扩展名
  static String _audioExtension(AudioStreamConfig config) {
    if (!config.copyMode) {
      final name = config.encoder.ffmpegName;
      if (name == 'libmp3lame') return 'mp3';
      if (name == 'flac') return 'flac';
    }
    return 'm4a'; // aac 及复制流
  }

  /// 为路径加上引号并转义，避免空格、中文、引号破坏命令
  static String _quote(String value) {
    final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    return '"$escaped"';
  }
}
