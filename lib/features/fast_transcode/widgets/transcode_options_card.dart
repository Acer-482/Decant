import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/domain/media/media_info.dart';
import 'package:media_transcoder/domain/media/stream_info/audio_stream_info.dart';
import 'package:media_transcoder/domain/media/stream_info/video_stream_info.dart';
import 'package:media_transcoder/shared/widgets/title_card.dart';

/// 转码选项卡片
class TranscodeOptionsCard extends ConsumerWidget {
  /// 媒体信息
  final MediaInfo mediaInfo;

  const TranscodeOptionsCard({super.key, required this.mediaInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TitleCard(
      icon: Icon(Icons.movie),
      title: Text('转码设置'),
      child: Column(children: [..._buildOptions(ref)]),
    );
  }

  /// 构建选项
  List<Widget> _buildOptions(WidgetRef ref) {
    final streams = mediaInfo.streams;
    return streams.map((st) {
      // 视频流
      if (st is VideoStreamInfo) {
        return Text('视频流 #${st.index}');
      } else // 音频流
      if (st is AudioStreamInfo) {
        return Text('视频流 #${st.index}');
      }
      return ListTile(dense: true, title: Text('未知流 #${st.index}'));
    }).toList();
  }
}
