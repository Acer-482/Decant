import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/domain/media/media_info.dart';
import 'package:decant/domain/media/media_input.dart';
import 'package:decant/domain/media/stream_info/video_stream_info.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:decant/features/fast_transcode/providers/media_info_provider.dart';
import 'package:decant/features/fast_transcode/utils/output_path.dart';
import 'package:decant/features/fast_transcode/widgets/file_info_card.dart';
import 'package:decant/features/fast_transcode/widgets/media_info_card.dart';
import 'package:decant/features/fast_transcode/widgets/transcode_options_card.dart';
import 'package:decant/shared/utils/file_utils.dart';
import 'package:decant/shared/utils/media_format_utils.dart';
import 'package:decant/shared/widgets/title_card.dart';

/// 转码工作台
class TranscodeOptionsPage extends ConsumerWidget {
  /// 输入源
  final List<BaseSource> sources;

  const TranscodeOptionsPage({super.key, required this.sources});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sources.isEmpty) return const SizedBox.shrink();

    final infos = [
      for (final source in sources) ref.watch(mediaInfoProvider(source.input)),
    ];

    return Container(
      padding: .all(10),
      child: Column(
        spacing: 10,
        children: [
          _buildSourceCard(context, ref, infos),
          Expanded(child: _buildOptionsBody(ref, infos)),
        ],
      ),
    );
  }

  /// 输入源卡片
  Widget _buildSourceCard(
    BuildContext context,
    WidgetRef ref,
    List<AsyncValue<MediaInfo>> infos,
  ) {
    return TitleCard(
      icon: const Icon(Icons.input),
      title: const Text('输入源'),
      child: Column(
        children: [
          for (var i = 0; i < sources.length; i++)
            _buildSourceRow(context, ref, i, infos[i]),
          Align(
            alignment: .centerLeft,
            child: TextButton.icon(
              onPressed: () => _addSource(ref),
              icon: const Icon(Icons.add),
              label: const Text('添加输入源'),
            ),
          ),
        ],
      ),
    );
  }

  /// 单个输入源行
  Widget _buildSourceRow(
    BuildContext context,
    WidgetRef ref,
    int index,
    AsyncValue<MediaInfo> info,
  ) {
    final source = sources[index];
    final name = source is FileSource
        ? FileUtils.fileName(source.path)
        : source.input;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
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
          if (sources.length > 1)
            IconButton(
              visualDensity: .compact,
              tooltip: '移除该输入',
              onPressed: () => ref
                  .read(fastTranscodeProvider.notifier)
                  .removeSourceAt(index),
              icon: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }

  /// 源摘要
  ///
  /// 时长 + 分辨率 + 流数
  String _summary(AsyncValue<MediaInfo> info) {
    if (info.isLoading) return '解析中…';
    if (!info.hasValue) return '解析失败';

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

  /// 流配置主体
  Widget _buildOptionsBody(WidgetRef ref, List<AsyncValue<MediaInfo>> infos) {
    if (infos.any((info) => info.isLoading)) {
      return const Center(child: CircularProgressIndicator());
    }

    for (final info in infos) {
      if (info.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: .center,
            spacing: 16,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              Text('获取媒体信息失败\n${info.error}', textAlign: .center),
              ElevatedButton(
                onPressed: () {
                  for (final source in sources) {
                    ref.invalidate(mediaInfoProvider(source.input));
                  }
                },
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }
    }

    final inputs = [
      for (var i = 0; i < sources.length; i++)
        MediaInput(source: sources[i], info: infos[i].requireValue),
    ];

    return SingleChildScrollView(
      child: TranscodeOptionsCard(
        inputs: inputs,
        outputPath: defaultOutputPath(sources),
      ),
    );
  }

  /// 追加输入源
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

  /// 查看完整媒体信息
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
}
