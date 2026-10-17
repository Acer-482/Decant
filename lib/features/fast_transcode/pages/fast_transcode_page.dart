import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/features/fast_transcode/pages/select_file_page.dart';
import 'package:media_transcoder/features/fast_transcode/pages/transcode_page.dart';
import 'package:media_transcoder/features/fast_transcode/pages/view_info_page.dart';
import 'package:media_transcoder/features/fast_transcode/providers/fast_transcode_provider.dart';

/// 快速转码页面
///
/// 为了美观，通过有限状态机的方式管理多个页面步骤
class FastTranscodePage extends ConsumerWidget {
  const FastTranscodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fastTranscodeProvider);
    return AnimatedSwitcher(
      duration: 600.ms,
      child: state.step == .selectFile
          ? const SelectFilePage()
          : state.step == .viewInfo
          ? const ViewInfoPage()
          : const TranscodePage(),
    );
  }
}
