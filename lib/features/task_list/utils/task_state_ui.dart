import 'package:media_transcoder/domain/task/task_state.dart';

extension TaskStateUi on TaskState {
  /// 显示名称
  String get displayName => switch (this) {
    .pending => '等待中',
    .running => '运行中',
    .completed => '已完成',
    .failed => '已失败',
    .cancelled => '已取消',
  };
}
