import 'package:dart_mappable/dart_mappable.dart';
import 'package:media_transcoder/domain/task/task_state.dart';
import 'package:media_transcoder/domain/task/base_task.dart';

part 'media_transcode_task.mapper.dart';

/// 媒体转码任务
@MappableClass(discriminatorValue: 'MediaTranscodeTask')
class MediaTranscodeTask extends BaseTask with MediaTranscodeTaskMappable {
  /// 路径
  final String path;

  const MediaTranscodeTask({
    required super.id,
    required super.name,
    super.notes,
    super.state,
    super.finishedStamp,
    required super.createdStamp,
    super.errorMessage,
    required this.path,
  });
}
