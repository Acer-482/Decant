import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/domain/media/media_info.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:decant/features/fast_transcode/providers/media_info_provider.dart';
import 'package:decant/features/fast_transcode/widgets/file_info_card.dart';
import 'package:decant/features/fast_transcode/widgets/media_info_card.dart';

/// 浏览信息页面
///
/// 支持多路输入：每个源单独展示卡片，可以继续追加或移除。
class ViewInfoPage extends ConsumerWidget {
  const ViewInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fastTranscodeProvider);
    final notifier = ref.read(fastTranscodeProvider.notifier);
    final sources = state.sources;

    // 逐源监听，路径作为缓存键，天然去重
    final infos = [
      for (final source in sources) ref.watch(mediaInfoProvider(source.input)),
    ];
    final ready = sources.isNotEmpty && infos.every((info) => info.hasValue);

    return Column(
      spacing: 10,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: 6,
              children: [
                const Divider(),
                for (var i = 0; i < sources.length; i++)
                  _SourceSection(
                        index: i,
                        source: sources[i],
                        info: infos[i],
                        onRemove: sources.length > 1
                            ? () => notifier.removeSourceAt(i)
                            : null,
                      )
                      .animate(delay: (300 + i * 200).ms)
                      .fadeIn(
                        duration: 600.ms,
                        curve: Curves.fastEaseInToSlowEaseOut,
                      )
                      .slideY(begin: 0.4),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => _addSource(ref),
                    icon: const Icon(Icons.add),
                    label: const Text('添加输入源'),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: ready ? () => notifier.startConfigOptions() : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('进入转码选项'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ],
    );
  }

  /// 追加一个输入源
  Future<void> _addSource(WidgetRef ref) async {
    final pickedFile = await FilePicker.pickFile(
      dialogTitle: '选择要追加的文件',
      windowsOptions: WindowsOptions(lockParentWindow: true),
    );
    if (pickedFile?.path == null) return;
    ref
        .read(fastTranscodeProvider.notifier)
        .addSource(FileSource(path: pickedFile!.path!));
  }
}

/// 单个输入源的信息区块
class _SourceSection extends StatelessWidget {
  /// 输入序号
  final int index;

  /// 源
  final BaseSource source;

  /// 该源的媒体信息
  final AsyncValue<MediaInfo> info;

  /// 移除回调（只有一个源时为 null）
  final VoidCallback? onRemove;

  const _SourceSection({
    required this.index,
    required this.source,
    required this.info,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        Row(
          children: [
            Text(
              '输入 ${index + 1}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                tooltip: '移除该输入',
                icon: const Icon(Icons.delete_outline, size: 18),
              ),
          ],
        ),
        if (source is FileSource)
          FileInfoCard(path: (source as FileSource).path),
        info.when(
          data: (mediaInfo) => MediaInfoCard(info: mediaInfo),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, _) => Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: const Text('无法解析该文件'),
              subtitle: Text('$error'),
            ),
          ),
        ),
      ],
    );
  }
}
