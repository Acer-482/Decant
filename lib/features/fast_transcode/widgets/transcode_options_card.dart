import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:decant/domain/media/media_input.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/media/stream_info/base_stream_info.dart';
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:decant/features/fast_transcode/utils/ffmpeg_args_builder.dart';
import 'package:decant/features/fast_transcode/utils/output_naming.dart';
import 'package:decant/features/fast_transcode/utils/output_path.dart';
import 'package:decant/features/fast_transcode/utils/stream_config_factory.dart';
import 'package:decant/features/fast_transcode/widgets/stream_tile.dart';
import 'package:decant/shared/utils/file_utils.dart';
import 'package:decant/shared/widgets/path_text.dart';
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
          _StreamEntry(stream: stream, config: defaultStreamConfig(stream, i)),
    ];
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

  /// 重命名主输出文件
  Future<void> _renameOutput(List<StreamConfig> mainConfigs) async {
    final sources = [for (final input in widget.inputs) input.source];
    final state = ref.read(fastTranscodeProvider);
    final outputDir = state.outputDir ?? defaultOutputDir(sources);
    final baseName = defaultBaseName(sources);
    final extension = extensionFor(mainConfigs);

    final current = p.basename(
      FfmpegArgsBuilder.mainPath(
        configs: mainConfigs,
        outputDir: outputDir,
        baseName: baseName,
        outputName: state.outputName,
      ),
    );

    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('输出文件名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: '文件名',
            helperText: '不写后缀时自动补 .$extension',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result == null) return; // 取消
    final name = result.trim();
    if (name.isEmpty) return;
    ref
        .read(fastTranscodeProvider.notifier)
        .setOutputName(ensureExtension(name, extension));
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

    // 主输出对应的流
    final mainConfigs = _entries
        .where((entry) => entry.config.enabled && !entry.config.separateOutput)
        .map((entry) => entry.config)
        .toList();
    final mainName = mainConfigs.isEmpty
        ? ''
        : p.basename(
            FfmpegArgsBuilder.mainPath(
              configs: mainConfigs,
              outputDir: outputDir,
              baseName: baseName,
              outputName: state.outputName,
            ),
          );
    final customName = state.outputName != null && state.outputName!.isNotEmpty;

    return TitleCard(
      icon: const Icon(Icons.movie),
      title: const Text('转码设置'),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          for (var input = 0; input < widget.inputs.length; input++) ...[
            if (widget.inputs.length > 1) _buildInputHeader(input),
            for (var i = 0; i < _entries.length; i++)
              if (_entries[i].config.inputIndex == input)
                _buildStreamTile(i, outputDir, baseName),
          ],
          const SizedBox(height: 16),
          Text(
            '输出',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 6),
          _buildOutputDirRow(theme, outputDir),
          if (mainConfigs.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildOutputNameRow(
              theme,
              mainName,
              custom: customName,
              onTap: () => _renameOutput(mainConfigs),
              onReset: () =>
                  ref.read(fastTranscodeProvider.notifier).setOutputName(null),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
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
              minimumSize: const Size.fromHeight(46),
            ),
          ),
        ],
      ),
    );
  }

  /// 单条流的设置面板
  Widget _buildStreamTile(int index, String outputDir, String baseName) {
    final entry = _entries[index];
    final customPath =
        entry.config.outputPath != null && entry.config.outputPath!.isNotEmpty;

    return StreamTile(
      key: ValueKey(entry.config.mapTarget),
      stream: entry.stream,
      config: entry.config,
      onChanged: (config) => _updateConfig(index, config),
      outputPath: FfmpegArgsBuilder.outputPathFor(
        entry.config,
        outputDir: outputDir,
        baseName: baseName,
      ),
      customPath: customPath,
      onPickPath: () => _pickStreamOutput(index, entry.config),
      onResetPath: () =>
          _updateConfig(index, entry.config.copyWith(outputPath: '')),
    );
  }

  /// 输出目录
  Widget _buildOutputDirRow(ThemeData theme, String outputDir) {
    return InkWell(
      onTap: _selectOutputDir,
      borderRadius: .circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: .circular(10),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              Icons.folder_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PathText(outputDir, style: theme.textTheme.bodySmall),
            ),
            const SizedBox(width: 8),
            Text(
              '更改',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 输出文件名
  Widget _buildOutputNameRow(
    ThemeData theme,
    String name, {
    required bool custom,
    required VoidCallback onTap,
    required VoidCallback onReset,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: .circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: .circular(10),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(child: PathText(name, style: theme.textTheme.bodySmall)),
            if (custom)
              InkWell(
                onTap: onReset,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.restart_alt,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Text(
              '重命名',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 输入分组标题
  Widget _buildInputHeader(int index) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.input, size: 13, color: theme.colorScheme.primary),
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
}

/// 流与其配置的配对
class _StreamEntry {
  /// 流信息
  final BaseStreamInfo stream;

  /// 流配置
  final StreamConfig config;

  const _StreamEntry({required this.stream, required this.config});
}
