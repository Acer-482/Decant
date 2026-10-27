import 'package:flutter/material.dart';
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

/// 文件行
class SourceRow extends ConsumerStatefulWidget {
  /// 输入源
  final BaseSource source;

  /// 序号
  final int number;

  /// 是否播放高亮
  final bool highlight;

  /// 是否显示分隔线
  final bool showDivider;

  const SourceRow({
    super.key,
    required this.source,
    required this.number,
    this.highlight = false,
    this.showDivider = false,
  });

  @override
  ConsumerState<SourceRow> createState() => _SourceRowState();
}

class _SourceRowState extends ConsumerState<SourceRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 180),
  );

  late final Animation<double> _size = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  // 只在创建时决定是否高亮，避免后续 rebuild 把它打断
  late final bool _highlight = widget.highlight;

  bool _leaving = false; // 正在执行删除动画

  @override
  void initState() {
    super.initState();
    _controller.forward(); // 入场
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 显示名
  String get _name {
    final source = widget.source;
    return source is FileSource
        ? FileUtils.fileName(source.path)
        : source.input;
  }

  /// 收起后再移除
  Future<void> _leave() async {
    if (_leaving) return;
    _leaving = true;
    await _controller.reverse();
    if (!mounted) return;
    ref.read(fastTranscodeProvider.notifier).removeSource(widget.source.input);
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(mediaInfoProvider(widget.source.input));
    final primary = Theme.of(context).colorScheme.primary;
    final row = Column(
      mainAxisSize: .min,
      children: [
        ListTile(
          dense: true,
          leading: CircleAvatar(radius: 12, child: Text('${widget.number}')),
          title: Text(_name, maxLines: 1, overflow: .ellipsis),
          subtitle: Text(_summary(info)),
          trailing: Row(
            mainAxisSize: .min,
            children: [
              IconButton(
                visualDensity: .compact,
                tooltip: '查看详情',
                onPressed: () => _showDetails(info),
                icon: const Icon(Icons.info_outline, size: 18),
              ),
              IconButton(
                visualDensity: .compact,
                tooltip: '移除',
                onPressed: _leave,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
        ),
        if (widget.showDivider) const Divider(height: 1),
      ],
    );

    return SizeTransition(
      sizeFactor: _size,
      alignment: .topCenter,
      child: FadeTransition(
        opacity: _fade,
        child: _highlight
            ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 1, end: 0),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOut,
                builder: (context, value, child) => ColoredBox(
                  color: primary.withValues(alpha: 0.16 * value),
                  child: child,
                ),
                child: row,
              )
            : row,
      ),
    );
  }

  /// 查看详情
  void _showDetails(AsyncValue<MediaInfo> info) {
    final source = widget.source;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(source is FileSource ? _name : '未知源信息'),
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
}
