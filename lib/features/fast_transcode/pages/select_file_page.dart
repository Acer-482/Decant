import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/domain/media/media_info.dart';
import 'package:decant/domain/media/stream_info/video_stream_info.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:decant/features/fast_transcode/providers/media_info_provider.dart';
import 'package:decant/features/fast_transcode/widgets/file_info_card.dart';
import 'package:decant/features/fast_transcode/widgets/media_info_card.dart';
import 'package:decant/shared/utils/file_utils.dart';
import 'package:decant/shared/utils/media_format_utils.dart';

/// 选择文件页面
///
/// 第一步展示各输入的媒体摘要，可一次拖入多个文件
class SelectFilePage extends ConsumerStatefulWidget {
  const SelectFilePage({super.key});

  @override
  ConsumerState<SelectFilePage> createState() => _SelectFilePageState();
}

class _SelectFilePageState extends ConsumerState<SelectFilePage> {
  // 正在拖拽文件
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fastTranscodeProvider);
    final sources = state.sources;
    final infos = [
      for (final source in sources) ref.watch(mediaInfoProvider(source.input)),
    ];
    final ready = sources.isNotEmpty && infos.every((info) => info.hasValue);

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) {
        setState(() => _dragging = false);
        _addPaths(details.files.map((file) => file.path).toList());
      },
      child: Padding(
        padding: .all(20),
        child: Column(
          spacing: 10,
          children: [
            Expanded(
              child: sources.isEmpty
                  ? _buildEmptyArea()
                  : _buildSourceList(sources, infos),
            ),
            if (sources.isNotEmpty)
              Align(
                alignment: .centerLeft,
                child: TextButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.add),
                  label: const Text('添加文件'),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: ready
                    ? () => ref
                          .read(fastTranscodeProvider.notifier)
                          .startConfigOptions()
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('下一步：配置转码'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 空状态区域
  Widget _buildEmptyArea() {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _pickFile,
      child: AnimatedContainer(
        duration: 120.ms,
        decoration: BoxDecoration(
          borderRadius: .all(.circular(5)),
          border: Border.all(
            color: _dragging
                ? theme.colorScheme.primary
                : theme.colorScheme.outline, // 边框色
            width: _dragging ? 2 : 1.5, // 边框粗细
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
            spacing: 8,
            children: [
              AnimatedSwitcher(
                duration: 100.ms,
                child: _dragging
                    ? _dragTip('dragging', Icons.file_download, '松开以添加文件')
                    : _dragTip('idle', Icons.add, '拖入或点击选择文件'),
              ),
              Text(
                '可以一次拖入多个文件，把它们的流合并到一个输出',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 文件列表
  Widget _buildSourceList(
    List<BaseSource> sources,
    List<AsyncValue<MediaInfo>> infos,
  ) {
    return Card(
      clipBehavior: .antiAlias,
      child: ListView.separated(
        itemCount: sources.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) =>
            _buildSourceRow(context, sources[index], infos[index], index),
      ),
    );
  }

  /// 文件行
  Widget _buildSourceRow(
    BuildContext context,
    BaseSource source,
    AsyncValue<MediaInfo> info,
    int index,
  ) {
    final name = source is FileSource
        ? FileUtils.fileName(source.path)
        : source.input;

    return ListTile(
      dense: true,
      leading: CircleAvatar(radius: 12, child: Text('${index + 1}')),
      title: Text(name, maxLines: 1, overflow: .ellipsis),
      subtitle: Text(_summary(info)),
      trailing: Row(
        mainAxisSize: .min,
        children: [
          IconButton(
            visualDensity: .compact,
            tooltip: '查看详情',
            onPressed: () => _showDetails(context, source, info),
            icon: const Icon(Icons.info_outline, size: 18),
          ),
          IconButton(
            visualDensity: .compact,
            tooltip: '移除',
            onPressed: () =>
                ref.read(fastTranscodeProvider.notifier).removeSourceAt(index),
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }

  /// 文件摘要
  String _summary(AsyncValue<MediaInfo> info) {
    if (info.isLoading) return '解析中…';
    if (!info.hasValue) return '解析失败，点击右侧详情查看原因';

    final media = info.requireValue;
    VideoStreamInfo? video;
    for (final stream in media.streams) {
      if (stream is VideoStreamInfo) {
        video = stream;
        break;
      }
    }

    final parts = <String>[
      MediaFormatUtils.duration(media.duration),
      if (video != null) '${video.width}×${video.height}',
      '${media.streams.length} 条流',
    ];
    return parts.join(' · ');
  }

  /// 追加文件
  ///
  /// 同路径自动去重
  void _addPaths(List<String> paths) {
    if (paths.isEmpty) return;
    ref
        .read(fastTranscodeProvider.notifier)
        .addSources(<BaseSource>[
          for (final path in paths) FileSource(path: path),
        ]);
  }

  /// 选择文件
  Future<void> _pickFile() async {
    final pickedFile = await FilePicker.pickFile(
      dialogTitle: '选择处理文件',
      windowsOptions: WindowsOptions(lockParentWindow: true),
    );
    if (pickedFile?.path == null) return; // 未选择文件
    _addPaths([pickedFile!.path!]);
  }

  /// 查看详情
  void _showDetails(
    BuildContext context,
    BaseSource source,
    AsyncValue<MediaInfo> info,
  ) {
    final title = source is FileSource
        ? FileUtils.fileName(source.path)
        : '媒体信息';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: .min,
              spacing: 8,
              children: [
                if (source is FileSource) FileInfoCard(path: source.path),
                if (info.hasValue) MediaInfoCard(info: info.requireValue),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 拖入提示
  Widget _dragTip(String keyValue, IconData iconData, String tip) {
    return Row(
      key: ValueKey(keyValue),
      spacing: 10,
      mainAxisAlignment: .center,
      children: [Icon(iconData), Text(tip)],
    );
  }
}
