/// 任务状态
enum TaskState {
  /// 等待中
  pending,

  /// 运行中
  running,

  /// 已完成
  completed,

  /// 已失败
  failed,

  /// 已取消
  cancelled,
}

extension TaskStateDisplay on TaskState {
  /// 显示名称
  String get displayName => switch (this) {
    .pending => '等待中',
    .running => '运行中',
    .completed => '已完成',
    .failed => '已失败',
    .cancelled => '已取消',
  };
}
