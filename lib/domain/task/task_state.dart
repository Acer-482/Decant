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
