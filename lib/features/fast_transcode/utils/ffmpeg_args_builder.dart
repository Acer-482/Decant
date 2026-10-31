import 'package:path/path.dart' as p;
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/media/stream_config/unknown_stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/features/fast_transcode/utils/output_naming.dart';

/// 一个输出文件
class FfmpegOutput {
  /// 最终路径
  final String path;

  /// 写入/临时 路径
  final String tempPath;

  /// 是否为主输出
  final bool main;

  const FfmpegOutput(this.path, {required this.tempPath, this.main = false});
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
  /// 同一个输出里有两路同类型流时，后写的会覆盖前面的
  static List<String> build(List<StreamConfig> configs) {
    final args = <String>[];

    var videoCount = 0; // 该输出里的第几条视频流
    var audioCount = 0; // 该输出里的第几条音频流
    var streamCount = 0; // 该输出里的第几条流

    for (final config in configs) {
      if (!config.enabled) continue; // 禁用的流不产生任何参数

      args.addAll(['-map', config.mapTarget]);

      switch (config) {
        case final VideoStreamConfig video:
          args.addAll([
            '-c:v:$videoCount',
            video.copyMode ? 'copy' : video.encoder.ffmpegName,
          ]);
          videoCount++;
        case final AudioStreamConfig audio:
          args.addAll([
            '-c:a:$audioCount',
            audio.copyMode ? 'copy' : audio.encoder.ffmpegName,
          ]);
          audioCount++;
        case final UnknownStreamConfig unknown:
          // 未知流没有区分 v/a/s，只能按流序号整体 copy
          if (unknown.copyMode) args.addAll(['-c:$streamCount', 'copy']);
      }

      streamCount++;
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

    final extension = extensionFor([config]);
    final suffix = switch (config) {
      VideoStreamConfig() => 'video',
      AudioStreamConfig() => 'audio',
      _ => 'stream${config.streamIndex}',
    };

    return p.join(outputDir, '${baseName}_$suffix.$extension');
  }

  /// 主输出的路径
  static String mainPath({
    required List<StreamConfig> configs,
    required String outputDir,
    required String baseName,
    String? outputName,
  }) {
    final extension = extensionFor(configs);

    if (outputName != null && outputName.isNotEmpty) {
      return p.join(outputDir, ensureExtension(outputName, extension));
    }

    return p.join(outputDir, '$baseName.$extension');
  }

  /// 先写临时文件，避免失败时留下一个"看起来正常"的残片
  static String tempPathFor(String path) {
    final dir = p.dirname(path);
    final name = p.basenameWithoutExtension(path);
    final extension = p.extension(path);
    return p.join(dir, '$name.part$extension');
  }

  /// 组装 FFmpeg 命令
  static FfmpegCommand buildCommand({
    required List<BaseSource> sources,
    required List<StreamConfig> configs,
    required String outputDir,
    required String baseName,
    String? outputName,
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

      final tempPath = tempPathFor(path);
      buffer.write(' ${build(group).join(' ')} ${_quote(tempPath)}');
      outputs.add(
        FfmpegOutput(path, tempPath: tempPath, main: outputs.isEmpty),
      );
    }

    addOutput(
      mainConfigs,
      mainPath(
        configs: mainConfigs,
        outputDir: outputDir,
        baseName: baseName,
        outputName: outputName,
      ),
    );
    for (final entry in groups.entries) {
      addOutput(entry.value, entry.key);
    }

    return FfmpegCommand(buffer.toString(), outputs);
  }

  /// 为路径加上引号并转义，避免空格、中文、引号破坏命令
  static String _quote(String value) {
    final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    return '"$escaped"';
  }
}
