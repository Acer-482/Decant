import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/features/fast_transcode/models/fast_transcode_state.dart';

/// 快速转码状态提供器
final fastTranscodeProvider =
    NotifierProvider<FastTranscodeNotifier, FastTranscodeState>(
      FastTranscodeNotifier.new,
    );

/// 快速转码监听器
class FastTranscodeNotifier extends Notifier<FastTranscodeState> {
  @override
  FastTranscodeState build() => const FastTranscodeState();

  /// 选择文件
  void selectFile(String path) {
    state = state.copyWith(step: .viewInfo, filePath: path);
  }

  /// 重置
  void reset() {
    state = const FastTranscodeState(); // 回到第一步
  }

  /// 下一步
  void nextStep() {
    if (state.step == .selectFile) {
      state = state.copyWith(step: .viewInfo);
    } else if (state.step == .viewInfo) {
      state = state.copyWith(step: .transcoding);
    } else if (state.step == .transcoding) {
      state = state.copyWith(step: .finish);
    }
  }
}
