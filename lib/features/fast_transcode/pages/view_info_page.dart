import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/features/fast_transcode/models/fast_transcode_state.dart';
import 'package:media_transcoder/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:media_transcoder/features/fast_transcode/providers/media_info_provider.dart';
import 'package:media_transcoder/features/fast_transcode/widgets/file_info_card.dart';
import 'package:media_transcoder/features/fast_transcode/widgets/media_info_card.dart';

/// 浏览信息页面
class ViewInfoPage extends ConsumerWidget {
  const ViewInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildInfoPage(ref);
  }

  /// 构建信息页面
  Widget _buildInfoPage(WidgetRef ref) {
    final state = ref.read(fastTranscodeProvider); // 状态
    final notifier = ref.read(fastTranscodeProvider.notifier); // 状态监听器
    return _buildInfoCardList(ref, state, notifier);
  }

  /// 构建信息列表
  Widget _buildInfoCardList(
    WidgetRef ref,
    FastTranscodeState state,
    FastTranscodeNotifier notifier,
  ) {
    final path = state.filePath!;
    final hasMediaInfo = ref.watch(mediaInfoProvider(path)).hasValue;
    return Column(
      spacing: 10,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: 6,
              children: [
                Divider(),
                ..._buildInfoCards(ref, state).indexed.map((entry) {
                  final (i, infoCard) = entry; // 解构
                  return infoCard
                      .animate(delay: (300 + i * 200).ms)
                      .fadeIn(
                        duration: 600.ms,
                        curve: Curves.fastEaseInToSlowEaseOut,
                      )
                      .slideY(begin: 0.4);
                }),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: hasMediaInfo ? () => notifier.nextStep() : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('开始转码'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建信息卡
  List<Widget> _buildInfoCards(WidgetRef ref, FastTranscodeState state) {
    final path = state.filePath!;
    final mediaAsyncInfo = ref.watch(mediaInfoProvider(path));
    return [
      FileInfoCard(path: path),

      // 媒体信息卡
      if (mediaAsyncInfo.hasValue)
        MediaInfoCard(info: mediaAsyncInfo.requireValue),
    ];
  }
}
