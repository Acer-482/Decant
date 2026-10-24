import 'package:dart_mappable/dart_mappable.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/domain/task/base_task.dart';
import 'package:decant/domain/task/task_state.dart';

part 'media_transcode_task.mapper.dart';

/// 媒体转码任务
@MappableClass(discriminatorValue: 'media_transcode')
class MediaTranscodeTask extends BaseTask with MediaTranscodeTaskMappable {
  /// 输入源
  final List<BaseSource> sources;

  /// 流配置
  final List<StreamConfig> streamConfigs;

  /// 输出路径
  final String outputPath;

  const MediaTranscodeTask({
    required super.id,
    required super.name,
    super.notes,
    super.state,
    super.finishedStamp,
    required super.createdStamp,
    super.errorMessage,
    required this.sources,
    required this.streamConfigs,
    required this.outputPath,
  });
}
