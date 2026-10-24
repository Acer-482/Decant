import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/features/fast_transcode/pages/select_file_page.dart';
import 'package:decant/features/fast_transcode/pages/transcode_options_page.dart';
import 'package:decant/features/fast_transcode/pages/transcoding_page.dart';
import 'package:decant/features/fast_transcode/pages/view_info_page.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';

/// 快速转码页面
///
/// 为了美观，通过有限状态机的方式管理多个页面步骤
class FastTranscodePage extends ConsumerWidget {
  const FastTranscodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fastTranscodeProvider); // 状态
    final notifier = ref.read(fastTranscodeProvider.notifier); // 状态监听器
    return Container(
      padding: .all(10),
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: 600.ms,
            child: switch (state.step) {
              .selectFile => const SelectFilePage(),
              .viewInfo => const ViewInfoPage(),
              .configureTranscodeOptions => TranscodeOptionsPage(
                sources: state.sources,
              ),
              .transcoding => TranscodingPage(sources: state.sources),
              .finish => const Center(child: Text('转码完成')),
            },
          ),
          if (state.step != .selectFile)
            Positioned(
              top: 2,
              right: 2,
              child: IconButton.filledTonal(
                onPressed: () => notifier.reset(), // 重置
                icon: Icon(Icons.cancel_outlined),
              ), // 取消按钮
            ), // 置于右上角
        ],
      ),
    );
  }
}
