import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:decant/domain/encoder/audio_encoder.dart';
import 'package:decant/domain/encoder/video_encoder.dart';
import 'package:decant/domain/media/media_input.dart';
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/media/stream_config/unknown_stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/domain/media/stream_info/audio_stream_info.dart';
import 'package:decant/domain/media/stream_info/base_stream_info.dart';
import 'package:decant/domain/media/stream_info/video_stream_info.dart';
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:decant/features/fast_transcode/utils/ffmpeg_args_builder.dart';
import 'package:decant/features/fast_transcode/utils/output_path.dart';
import 'package:decant/shared/utils/file_utils.dart';
import 'package:decant/shared/widgets/title_card.dart';

/// 转码选项卡片
///
/// 多路输入时按输入分组，每条流映射到「输入序号:流序号」
class TranscodeOptionsCard extends ConsumerStatefulWidget {
  /// 输入媒体
  final List<MediaInput> inputs;

  const TranscodeOptionsCard({super.key, required this.inputs});

  @override
  ConsumerState<TranscodeOptionsCard> createState() =>
      _TranscodeOptionsCardState();
}

class _TranscodeOptionsCardState extends ConsumerState<TranscodeOptionsCard> {
  /// 流与配置的配对
  late final List<_StreamEntry> _entries = _buildEntries();

  /// 构建初始配置
  List<_StreamEntry> _buildEntries() {
    return [
      for (var i = 0; i < widget.inputs.length; i++)
        for (final stream in widget.inputs[i].info.streams)
          _StreamEntry(stream: stream, config: _defaultConfig(stream, i)),
    ];
  }

  /// 默认配置
  StreamConfig _defaultConfig(BaseStreamInfo stream, int inputIndex) {
    if (stream is VideoStreamInfo) {
      return VideoStreamConfig(
        inputIndex: inputIndex,
        streamIndex: stream.index,
        encoder: VideoEncoder.values.firstWhere(
          (encoder) =>
              encoder.codec.ffprobeName == stream.codecName && // 默认编码器
              encoder.type == .software, // 软件
          orElse: () => .libx264, // 兜底使用软件编码
        ),
      );
    }

    if (stream is AudioStreamInfo) {
      return AudioStreamConfig(
        inputIndex: inputIndex,
        streamIndex: stream.index,
        encoder: AudioEncoder.values.firstWhere(
          (encoder) => encoder.codec.ffprobeName == stream.codecName,
          orElse: () => .aac, // 兜底使用通用格式
        ),
      );
    }

    return UnknownStreamConfig(
      inputIndex: inputIndex,
      streamIndex: stream.index,
    );
  }

  /// 更新配置
  void _updateConfig(int index, StreamConfig config) {
    setState(() {
      _entries[index] = _StreamEntry(
        stream: _entries[index].stream,
        config: config,
      );
    });
  }

  /// 选择输出目录
  Future<void> _selectOutputDir() async {
    final dir = await getDirectoryPath();
    if (dir == null) return; // 用户取消
    ref.read(fastTranscodeProvider.notifier).setOutputDir(dir);
  }

  /// 选择某条流的输出路径
  Future<void> _pickStreamOutput(int index, StreamConfig config) async {
    final sources = [for (final input in widget.inputs) input.source];
    final state = ref.read(fastTranscodeProvider);
    final outputDir = state.outputDir ?? defaultOutputDir(sources);
    final baseName = defaultBaseName(sources);

    final suggested = FfmpegArgsBuilder.outputPathFor(
      config,
      outputDir: outputDir,
      baseName: baseName,
    );

    final location = await getSaveLocation(
      suggestedName: p.basename(suggested),
    );
    if (location == null) return; // 用户取消
    _updateConfig(index, config.copyWith(outputPath: location.path));
  }

  /// 输入显示名
  String _inputLabel(int index) {
    final source = widget.inputs[index].source;
    if (source is FileSource) return FileUtils.fileName(source.path);
    return source.input;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sources = [for (final input in widget.inputs) input.source];
    final state = ref.watch(fastTranscodeProvider);
    final outputDir = state.outputDir ?? defaultOutputDir(sources);
    final baseName = defaultBaseName(sources);
    final hasEnabled = _entries.any((entry) => entry.config.enabled);

    return TitleCard(
      icon: const Icon(Icons.movie),
      title: const Text('转码设置'),
      child: Column(
        children: [
          for (var input = 0; input < widget.inputs.length; input++) ...[
            if (widget.inputs.length > 1) _buildInputHeader(input),
            for (var i = 0; i < _entries.length; i++)
              if (_entries[i].config.inputIndex == input) _buildStreamTile(i),
          ],
          const Divider(height: 24),
          // 输出目录
          ListTile(
            dense: true,
            onTap: _selectOutputDir,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.folder_outlined, size: 18),
            title: const Text('输出目录'),
            subtitle: Text(outputDir, maxLines: 1, overflow: .ellipsis),
            trailing: const Text('更改'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 8),
            child: Text(
              '主文件 $baseName.mp4；勾选「单独输出」的流会生成 _video / _audio 文件',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: hasEnabled
                  ? () {
                      ref
                          .read(fastTranscodeProvider.notifier)
                          .startTranscoding(
                            _entries.map((entry) => entry.config).toList(),
                          ); // 存入配置 开始转码
                    }
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('开始转码'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 输入分组标题
  Widget _buildInputHeader(int index) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Row(
        children: [
          Icon(Icons.input, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '输入 ${index + 1} · ${_inputLabel(index)}',
              maxLines: 1,
              overflow: .ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 流设置面板
  Widget _buildStreamTile(int index) {
    final entry = _entries[index];
    final stream = entry.stream;
    final config = entry.config;

    // 获取流显示名称
    String title = '未知流 #${stream.index}';
    if (stream is VideoStreamInfo) {
      title = '视频流 #${stream.index}';
    } else if (stream is AudioStreamInfo) {
      title = '音频流 #${stream.index}';
    } else {
      return ListTile(
        title: Text(title),
        subtitle: const Text('当前不支持的流类型'),
        enabled: false,
      );
    }

    return ExpansionTile(
      title: Text(title), // 标题
      subtitle: Text(
        !config.enabled
            ? '已禁用'
            : "${config.copyMode ? '复制原流' : '重新编码'}${config.separateOutput ? ' | 单独输出' : ''}",
      ),
      shape: RoundedRectangleBorder(borderRadius: .circular(12)), // 展开形状
      collapsedShape: RoundedRectangleBorder(
        borderRadius: .circular(12),
      ), // 收起形状
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        // 是否启用
        SwitchListTile(
          title: const Text('启用该流'),
          value: config.enabled,
          onChanged: (val) =>
              _updateConfig(index, config.copyWith(enabled: val)),
        ),
        // 是否复制流
        if (config.enabled) ...[
          SwitchListTile(
            title: const Text('复制流'),
            subtitle: const Text('速度最快且完全无损'),
            value: config.copyMode,
            onChanged: (val) =>
                _updateConfig(index, config.copyWith(copyMode: val)),
          ),
          if (!config.copyMode) _buildEncoderSelector(index, stream, config),
          SwitchListTile(
            title: const Text('单独输出'),
            subtitle: const Text('这条流写入独立文件'),
            value: config.separateOutput,
            onChanged: (val) =>
                _updateConfig(index, config.copyWith(separateOutput: val)),
          ),
          if (config.separateOutput) _buildOutputPathTile(index, config),
        ],
      ],
    );
  }

  /// 单独输出的路径选择
  Widget _buildOutputPathTile(int index, StreamConfig config) {
    final sources = [for (final input in widget.inputs) input.source];
    final state = ref.watch(fastTranscodeProvider);
    final outputDir = state.outputDir ?? defaultOutputDir(sources);
    final baseName = defaultBaseName(sources);

    final path = FfmpegArgsBuilder.outputPathFor(
      config,
      outputDir: outputDir,
      baseName: baseName,
    );
    final custom = config.outputPath != null && config.outputPath!.isNotEmpty;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: const Text('输出路径'),
      subtitle: Text(path, maxLines: 1, overflow: .ellipsis),
      trailing: Row(
        mainAxisSize: .min,
        children: [
          if (custom)
            IconButton(
              visualDensity: .compact,
              tooltip: '恢复默认',
              onPressed: () =>
                  _updateConfig(index, config.copyWith(outputPath: '')),
              icon: const Icon(Icons.restart_alt, size: 18),
            ),
          TextButton(
            onPressed: () => _pickStreamOutput(index, config),
            child: const Text('更改'),
          ),
        ],
      ),
    );
  }

  /// 编码器选择
  Widget _buildEncoderSelector(
    int index,
    BaseStreamInfo stream,
    StreamConfig config,
  ) {
    if (stream is VideoStreamInfo && config is VideoStreamConfig) {
      return DropdownButtonFormField<VideoEncoder>(
        initialValue: config.encoder,
        decoration: const InputDecoration(labelText: '视频编码器'),
        items: VideoEncoder.values.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text('${e.codec.displayName} (${e.ffmpegName})'),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) _updateConfig(index, config.copyWith(encoder: val));
        },
      );
    }

    if (stream is AudioStreamInfo && config is AudioStreamConfig) {
      return DropdownButtonFormField<AudioEncoder>(
        initialValue: config.encoder,
        decoration: const InputDecoration(labelText: '音频编码器'),
        items: AudioEncoder.values.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text('${e.codec.displayName} (${e.ffmpegName})'),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) _updateConfig(index, config.copyWith(encoder: val));
        },
      );
    }

    return const SizedBox.shrink();
  }
}

/// 流与其配置的配对
class _StreamEntry {
  /// 流信息
  final BaseStreamInfo stream;

  /// 流配置
  final StreamConfig config;

  const _StreamEntry({required this.stream, required this.config});
}
