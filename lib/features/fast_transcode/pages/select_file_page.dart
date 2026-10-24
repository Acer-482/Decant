import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';

/// 选择文件页面
class SelectFilePage extends ConsumerStatefulWidget {
  const SelectFilePage({super.key});

  @override
  ConsumerState<SelectFilePage> createState() => _SelectFilePageState();
}

class _SelectFilePageState extends ConsumerState<SelectFilePage> {
  bool _dragging = false; // 正在拖拽文件

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(20),
      child: Column(
        mainAxisAlignment: .center,
        mainAxisSize: .max,
        children: [Expanded(child: _buildPickFileArea())],
      ),
    );
  }

  /// 设置选中的文件
  void _setSelectedFiles(List<String> paths) {
    if (paths.isEmpty) return;
    final notifier = ref.read(fastTranscodeProvider.notifier);
    notifier.selectSource(FileSource(path: paths.first));
    for (final path in paths.skip(1)) {
      notifier.addSource(FileSource(path: path));
    }
  }

  /// 选择文件
  Future<void> _pickFile() async {
    final pickedFile = await FilePicker.pickFile(
      dialogTitle: '选择处理文件',
      windowsOptions: WindowsOptions(lockParentWindow: true),
    );
    if (pickedFile?.path == null) return; // 未选择文件
    // 选择成功 //
    _setSelectedFiles([pickedFile!.path!]);
  }

  /// 处理拖入文件
  void _handleDrop(List<DropItem> files) {
    if (files.isEmpty) return;
    _setSelectedFiles(files.map((f) => f.path).toList());
  }

  /// 构建选择文件区域
  Widget _buildPickFileArea() {
    final theme = Theme.of(context);
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) {
        setState(() => _dragging = false);
        _handleDrop(details.files);
      },
      child: GestureDetector(
        onTap: () => _pickFile(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: .all(.circular(5)),
            border: Border.all(
              color: theme.colorScheme.outline, // 边框色
              width: 1.5, // 边框粗细
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                AnimatedSwitcher(
                  duration: 100.ms,
                  child: _dragging
                      ? _dragTip('dragging', Icons.file_download, '松开以添加文件')
                      : _dragTip('idle', Icons.add, '拖入或点击选择文件'),
                ),
              ],
            ),
          ),
        ),
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
