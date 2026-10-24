import 'package:dart_mappable/dart_mappable.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/features/fast_transcode/enums/fast_transcode_step.dart';

part 'fast_transcode_state.mapper.dart';

/// 快速转码状态
@MappableClass()
class FastTranscodeState with FastTranscodeStateMappable {
  /// 当前步骤
  final FastTranscodeStep step;

  /// 输入源
  final List<BaseSource> sources;

  /// 转码配置
  final List<StreamConfig> streamConfigs;

  const FastTranscodeState({
    this.step = .selectFile,
    this.sources = const [],
    this.streamConfigs = const [],
  });

  /// 是否至少有一个输入源
  bool get hasSources => sources.isNotEmpty;
}
