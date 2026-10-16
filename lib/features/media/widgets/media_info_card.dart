import 'package:ffmpeg_kit_flutter_new/media_information.dart';
import 'package:flutter/material.dart';
import 'package:media_transcoder/features/media/widgets/media_info_content.dart';
import 'package:media_transcoder/shared/widgets/title_card.dart';

/// 媒体信息卡
class MediaInfoCard extends StatelessWidget {
  final MediaInformation info;

  const MediaInfoCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return TitleCard(
      icon: const Icon(Icons.movie_outlined),
      title: const Text('媒体信息'),
      child: MediaInfoContent(info: info),
    );
  }
}
