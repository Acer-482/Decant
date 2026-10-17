import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/shared/widgets/title_card.dart';

/// 转码设置卡片
class TranscodeSettingCard extends ConsumerWidget {
  const TranscodeSettingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TitleCard(
      icon: Icon(Icons.movie),
      title: Text('转码设置'),
      child: Column(children: [ListTile(title: Text('目标格式'))]),
    );
  }
}
