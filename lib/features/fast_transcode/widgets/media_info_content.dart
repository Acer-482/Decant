import 'package:flutter/material.dart';
import 'package:media_transcoder/domain/codec/audio_codec.dart';
import 'package:media_transcoder/domain/codec/media_codec.dart';
import 'package:media_transcoder/domain/codec/video_codec.dart';
import 'package:media_transcoder/domain/media/media_info.dart';
import 'package:media_transcoder/domain/media/stream_info/audio_stream_info.dart';
import 'package:media_transcoder/domain/media/stream_info/video_stream_info.dart';
import 'package:media_transcoder/shared/utils/file_utils.dart';
import 'package:media_transcoder/shared/utils/media_format_utils.dart';
import 'package:media_transcoder/shared/widgets/info_row.dart';

/// 媒体信息
class MediaInfoContent extends StatelessWidget {
  /// 媒体信息
  final MediaInfo info;

  const MediaInfoContent({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final videoStreams = info.streams.whereType<VideoStreamInfo>().toList();
    final audioStreams = info.streams.whereType<AudioStreamInfo>().toList();
    return Column(
      spacing: 8,
      children: [
        InfoRow(title: '时长', info: MediaFormatUtils.duration(info.duration)),
        InfoRow(title: '大小', info: FileUtils.fileSizeStr(info.size)),
        InfoRow(title: '码率', info: MediaFormatUtils.bitRate(info.bitrate)),
        for (final s in videoStreams) ...[
          _GroupTitle(icon: Icons.movie, text: '视频流 #${s.index}'),
          ..._buildVideoRows(s),
        ],
        for (final s in audioStreams) ...[
          _GroupTitle(icon: Icons.music_note, text: '音频流 #${s.index}'),
          ..._buildAudioRows(s),
        ],
      ],
    );
  }

  List<Widget> _buildVideoRows(VideoStreamInfo s) {
    return [
      InfoRow(title: '编码', info: _codecLabel(s.codecName)),
      InfoRow(title: '分辨率', info: '${s.width} × ${s.height}'),
      if (s.frameRate != null)
        InfoRow(title: '帧率', info: MediaFormatUtils.frameRate(s.frameRate)),
      if (s.bitRate != null)
        InfoRow(title: '码率', info: MediaFormatUtils.bitRate(s.bitRate)),
      if (s.pixFmt.isNotEmpty) InfoRow(title: '像素格式', info: s.pixFmt),
      if (s.colorSpace != null) InfoRow(title: '色彩空间', info: s.colorSpace!),
      if (s.profile != null) InfoRow(title: '配置', info: s.profile!),
    ];
  }

  List<Widget> _buildAudioRows(AudioStreamInfo s) {
    return [
      InfoRow(title: '编码', info: _codecLabel(s.codecName)),
      InfoRow(
        title: '采样率',
        info: MediaFormatUtils.sampleRate(s.sampleRate.toString()),
      ),
      InfoRow(
        title: '声道',
        info: MediaFormatUtils.channelLayout(s.channelLayout, s.channels),
      ),
      if (s.bitRate != null)
        InfoRow(title: '码率', info: MediaFormatUtils.bitRate(s.bitRate)),
    ];
  }

  String _codecLabel(String codecName) {
    if (codecName.isEmpty) return '未知';
    // 查找类型
    final videoMatch = VideoCodec.values
        .where((t) => t.ffprobeName == codecName)
        .firstOrNull;
    final audioMatch = AudioCodec.values
        .where((t) => t.ffprobeName == codecName)
        .firstOrNull;
    final MediaCodec? match = videoMatch ?? audioMatch;
    return match?.displayName ?? '${codecName.toUpperCase()} (未知编码)';
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
