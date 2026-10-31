import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/features/fast_transcode/pages/select_file_page.dart';
import 'package:decant/features/fast_transcode/pages/transcode_options_page.dart';
import 'package:decant/features/fast_transcode/pages/transcoding_page.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';

/// 快速转码页面
///
/// 为了美观，通过有限状态机的方式管理多个页面：选择文件 → 配置→ 转码
class FastTranscodePage extends ConsumerStatefulWidget {
  const FastTranscodePage({super.key});

  @override
  ConsumerState<FastTranscodePage> createState() => _FastTranscodePageState();
}

class _FastTranscodePageState extends ConsumerState<FastTranscodePage>
    with AutomaticKeepAliveClientMixin {
  // 切到其他标签页时保留当前步骤与转码进度
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 保活所必需

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
