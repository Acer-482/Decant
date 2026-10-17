import 'package:ffmpeg_kit_flutter_new/media_information.dart';
import 'package:ffmpeg_kit_flutter_new/stream_information.dart';
import 'package:flutter/material.dart';
import 'package:media_transcoder/domain/codec/audio_codec.dart';
import 'package:media_transcoder/domain/codec/video_codec.dart';
import 'package:media_transcoder/shared/utils/file_utils.dart';
import 'package:media_transcoder/shared/utils/media_format_utils.dart';
import 'package:media_transcoder/shared/widgets/info_row.dart';

/// 媒体信息
class MediaInfoContent extends StatelessWidget {
  /// 媒体信息
  final MediaInformation info;

  const MediaInfoContent({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final streams = info.getStreams();
    final videoStreams = streams.where((s) => s.getType() == 'video').toList();
    final audioStreams = streams.where((s) => s.getType() == 'audio').toList();
    return Column(
      spacing: 8,
      children: [
        InfoRow(
          title: '时长',
          info: MediaFormatUtils.duration(info.getDuration()),
        ),
        InfoRow(title: '大小', info: FileUtils.fileSizeStr(info.getSize())),
        InfoRow(title: '码率', info: MediaFormatUtils.bitRate(info.getBitrate())),
        for (final s in videoStreams) ...[
          _GroupTitle(icon: Icons.movie, text: '视频流 #${s.getIndex()}'),
          ..._buildVideoRows(s),
        ],
        for (final s in audioStreams) ...[
          _GroupTitle(icon: Icons.music_note, text: '音频流 #${s.getIndex()}'),
          ..._buildAudioRows(s),
        ],
      ],
    );
  }

  List<Widget> _buildVideoRows(StreamInformation s) {
    return [
      InfoRow(title: '编码', info: _codecLabel(s)),
      InfoRow(title: '分辨率', info: '${s.getWidth()} × ${s.getHeight()}'),
      InfoRow(
        title: '帧率',
        info: MediaFormatUtils.frameRate(s.getRealFrameRate()),
      ),
      InfoRow(
        title: '帧率 (平均)',
        info: MediaFormatUtils.frameRate(s.getAverageFrameRate()),
      ),
      if (s.getBitrate() != null)
        InfoRow(title: '码率', info: MediaFormatUtils.bitRate(s.getBitrate())),
      if (s.getFormat() != null) InfoRow(title: '像素格式', info: s.getFormat()!),
      if (s.getStringProperty('color_space') != null)
        InfoRow(title: '色彩空间', info: s.getStringProperty('color_space')!),
    ];
  }

  List<Widget> _buildAudioRows(StreamInformation s) {
    return [
      InfoRow(title: '编码', info: _codecLabel(s)),
      InfoRow(
        title: '采样率',
        info: MediaFormatUtils.sampleRate(s.getSampleRate()),
      ),
      InfoRow(
        title: '声道',
        info: MediaFormatUtils.channelLayout(
          s.getChannelLayout(),
          s.getNumberProperty('channels')?.toInt(),
        ),
      ),
      if (s.getBitrate() != null)
        InfoRow(title: '码率', info: MediaFormatUtils.bitRate(s.getBitrate())),
    ];
  }

  String _codecLabel(StreamInformation s) {
    final codec = s.getCodec(); // 编码格式
    if (codec == null) return '未知';
    return VideoCodec.values
            .where((t) => t.ffprobeName == codec)
            .firstOrNull
            ?.displayName ??
        AudioCodec.values
            .where((t) => t.ffprobeName == codec)
            .firstOrNull
            ?.displayName ??
        '${codec.toUpperCase()} (未知编码格式)';
  }
}

/// 分组小标题
class _GroupTitle extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GroupTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
