import 'package:flutter/material.dart';
import 'package:decant/domain/media/media_info.dart';
import 'package:decant/features/fast_transcode/widgets/media_info_content.dart';
import 'package:decant/shared/widgets/title_card.dart';

/// 媒体信息卡
class MediaInfoCard extends StatelessWidget {
  final MediaInfo info;

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
