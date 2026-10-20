import 'package:dart_mappable/dart_mappable.dart';
import 'package:media_transcoder/domain/media/stream_config/stream_config.dart';
import 'package:media_transcoder/features/fast_transcode/enums/fast_transcode_step.dart';

part 'fast_transcode_state.mapper.dart';

/// 快速转码状态
@MappableClass()
class FastTranscodeState with FastTranscodeStateMappable {
  /// 当前步骤
  final FastTranscodeStep step;

  /// 文件路径
  final String? filePath;

  /// 转码配置
  final List<StreamConfig> streamConfigs;

  const FastTranscodeState({
    this.step = .selectFile,
    this.filePath,
    this.streamConfigs = const [],
  });
}
