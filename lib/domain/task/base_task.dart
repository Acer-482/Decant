import 'package:dart_mappable/dart_mappable.dart';
import 'package:media_transcoder/domain/task/task_state.dart';

part 'base_task.mapper.dart';

/// 任务基类
@MappableClass(discriminatorKey: 'type')
abstract class BaseTask with BaseTaskMappable {
  /// 任务ID
  final String id;

  /// 任务名称
  final String name;

  /// 任务备注
  final String notes;

  /// 任务状态
  final TaskState state;

  /// 任务完成时间戳
  final DateTime? finishedStamp;

  /// 任务创建时间戳
  final DateTime createdStamp;

  /// 错误信息
  final String? errorMessage;

  const BaseTask({
    required this.id,
    required this.name,
    this.notes = '',
    this.state = .pending,
    this.finishedStamp,
    required this.createdStamp,
    this.errorMessage,
  });
}
