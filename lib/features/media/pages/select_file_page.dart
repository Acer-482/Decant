import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/features/media/providers/media_info_provider.dart';
import 'package:media_transcoder/features/media/widgets/file_info_card.dart';
import 'package:media_transcoder/features/media/widgets/media_info_card.dart';

/// 选择文件页面
class SelectFilePage extends ConsumerStatefulWidget {
  const SelectFilePage({super.key});

  @override
  ConsumerState<SelectFilePage> createState() => _SelectFilePageState();
}

class _SelectFilePageState extends ConsumerState<SelectFilePage> {
  bool _dragging = false; // 正在拖拽文件

  String? _selectedFile; // 选中的文件

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 600.ms,
      child: _selectedFile == null
          ? Padding(
              padding: .all(20),
              child: Column(
                mainAxisAlignment: .center,
                mainAxisSize: .max,
                children: [Expanded(child: _buildPickFileArea())],
              ),
            )
          : _buildInfoPage(),
    ); // 动画切换
  }

  /// 设置选中文件
  void _setSelectedFile(String? path) {
    setState(() => _selectedFile = path);
  }

  /// 选择文件
  Future<void> _pickFile() async {
    final pickedFile = await FilePicker.pickFile(
      dialogTitle: '选择处理文件',
      windowsOptions: WindowsOptions(lockParentWindow: true),
    );
    if (pickedFile?.path == null) return; // 未选择文件
    // 选择成功 //
    _setSelectedFile(pickedFile!.path!);
  }

  /// 处理拖入文件
  void _handleDrop(List<DropItem> files) {
    if (files.isEmpty) return;
    _setSelectedFile(files.first.path);
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

  /// 构建信息卡
  List<Widget> _buildInfoCards() {
    final path = _selectedFile!;
    final mediaAsyncInfo = ref.watch(mediaInfoProvider(path));
    return [
      FileInfoCard(path: path),

      // 媒体信息卡
      if (mediaAsyncInfo.hasValue)
        MediaInfoCard(info: mediaAsyncInfo.requireValue),
    ];
  }

  /// 构建信息页面
  Widget _buildInfoPage() {
    return Container(
      padding: .all(10),
      child: Stack(
        children: [
          _buildInfoCardList(),
          Positioned(
            top: 2,
            right: 2,
            child: IconButton.filledTonal(
              onPressed: () => _setSelectedFile(null),
              icon: Icon(Icons.cancel_outlined),
            ), // 取消按钮
          ), // 置于右上角
        ],
      ),
    );
  }

  /// 构建信息列表
  Widget _buildInfoCardList() {
    return Column(
      spacing: 10,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: 6,
              children: [
                Divider(),
                ..._buildInfoCards().indexed.map((entry) {
                  final (i, infoCard) = entry; // 解构
                  return infoCard
                      .animate(delay: (300 + i * 200).ms)
                      .fadeIn(
                        duration: 600.ms,
                        curve: Curves.fastEaseInToSlowEaseOut,
                      )
                      .slideY(begin: 0.4);
                }),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: ref.watch(mediaInfoProvider(_selectedFile!)).hasValue
                ? () {}
                : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('开始转码'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ],
    );
  }
}
