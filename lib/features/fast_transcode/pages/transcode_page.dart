import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/features/fast_transcode/widgets/transcode_setting_card.dart';

/// 转码页面
class TranscodePage extends ConsumerWidget {
  const TranscodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: .all(10),
      child: Column(children: [TranscodeSettingCard()]),
    );
  }
}
