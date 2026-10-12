import 'package:flutter/material.dart';
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

  /// 显示颜色
  Color get displayColor => switch (this) {
    .pending => Colors.grey,
    .running => Colors.blue,
    .completed => Colors.green,
    .failed => Colors.red,
    .cancelled => Colors.tealAccent,
  };
}
