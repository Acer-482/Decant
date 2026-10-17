import 'package:media_transcoder/features/fast_transcode/enums/fast_transcode_step.dart';

/// 快速转码状态
class FastTranscodeState {
  /// 当前步骤
  final FastTranscodeStep step;

  /// 文件路径
  final String? filePath;

  const FastTranscodeState({this.step = .selectFile, this.filePath});

  FastTranscodeState copyWith({FastTranscodeStep? step, String? filePath}) {
    return FastTranscodeState(
      step: step ?? this.step,
      filePath: filePath ?? this.filePath,
    );
  }
}
