import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:decant/features/fast_transcode/providers/media_info_provider.dart';
import 'package:decant/features/fast_transcode/widgets/source_row.dart';

/// 选择文件页面
class SelectFilePage extends ConsumerStatefulWidget {
  const SelectFilePage({super.key});

  @override
  ConsumerState<SelectFilePage> createState() => _SelectFilePageState();
}

class _SelectFilePageState extends ConsumerState<SelectFilePage> {
  // 正在拖拽文件
  bool _dragging = false;

  // 已经播放过入场动画的文件
  final Set<String> _seen = {};

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
            Expanded(child: _buildFrame(sources)),
            // 没有文件时不显示
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: sources.isNotEmpty && ready
                    ? () => ref
                          .read(fastTranscodeProvider.notifier)
                          .startConfigOptions()
                    : null, // 未就绪时置灰
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

  /// 文件列表 + 拖入区域
  Widget _buildFrame(List<BaseSource> sources) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: 120.ms,
      clipBehavior: .antiAlias,
      decoration: BoxDecoration(
        borderRadius: .all(.circular(6)),
        border: Border.all(
          color: _dragging
              ? theme.colorScheme.primary
              : theme.colorScheme.outline, // 边框色
          width: _dragging ? 2 : 1.5, // 边框粗细
        ),
      ),
      child: Column(
        children: [
          // 文件列表在上
          if (sources.isNotEmpty) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: _buildSourceList(sources),
            ),
            const Divider(height: 1),
          ],
          // 拖入区域在下
          Expanded(child: _buildDropZone()),
        ],
      ),
    );
  }

  /// 拖入区域
  Widget _buildDropZone() {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: .opaque,
      onTap: _pickFile,
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
    );
  }

  /// 文件列表
  Widget _buildSourceList(List<BaseSource> sources) {
    return ListView.builder(
      shrinkWrap: true, // 按内容高度
      padding: EdgeInsets.zero,
      itemCount: sources.length,
      // 删除/插入后按下标复用会重建整行，这里按 key 找回原位置以保留 State
      findChildIndexCallback: (key) {
        if (key is! ValueKey<String>) return null;
        final index = sources.indexWhere((source) => source.input == key.value);
        return index < 0 ? null : index;
      },
      itemBuilder: (context, index) {
        final source = sources[index];
        return SourceRow(
          key: ValueKey(source.input),
          source: source,
          number: index + 1,
          highlight: _seen.add(source.input), // 第一次出现时播放高亮
          showDivider: index < sources.length - 1,
        );
      },
    );
  }

  /// 追加文件
  ///
  /// 同路径自动去重
  void _addPaths(List<String> paths) {
    if (paths.isEmpty) return;
    ref.read(fastTranscodeProvider.notifier).addSources(<BaseSource>[
      for (final path in paths) FileSource(path: path),
    ]);
  }

  /// 选择文件
  Future<void> _pickFile() async {
    final pickedFiles = await FilePicker.pickFiles(
      dialogTitle: '选择处理文件',
      windowsOptions: WindowsOptions(lockParentWindow: true),
    );
    if (pickedFiles.isEmpty) return; // 未选择文件
    _addPaths([
      for (final file in pickedFiles)
        if (file.path != null) file.path!,
    ]);
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
