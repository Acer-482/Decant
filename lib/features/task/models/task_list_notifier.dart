import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/features/task/models/task/base_task.dart';

/// 任务列表提供器
final taskListProvider =
    NotifierProvider<TaskListNotifier, Map<String, BaseTask>>(
      TaskListNotifier.new,
    );

/// 任务列表提供器
///
/// 按创建时间倒序
final sortedTaskListProvider = Provider<List<BaseTask>>((ref) {
  final tasks = ref.watch(taskListProvider).values.toList();
  tasks.sort((a, b) => b.createdStamp.compareTo(a.createdStamp)); // 按创建时间倒序
  return tasks;
});

/// 任务列表监听器
class TaskListNotifier extends Notifier<Map<String, BaseTask>> {
  @override
  Map<String, BaseTask> build() {
    return {};
  }

  /// 添加任务
  ///
  /// 已添加时返回false
  Future<bool> add(BaseTask task) async {
    if (state.containsKey(task.id)) return false; // 是否已经存在
    state[task.id] = task;
    ref.notifyListeners(); // 更新监听
    return true;
  }

  /// 更新任务
  ///
  /// 不存在时返回false
  Future<bool> update(BaseTask task) async {
    if (!state.containsKey(task.id)) return false; // 是否不存在
    state[task.id] = task;
    ref.notifyListeners(); // 更新监听
    return true;
  }

  /// 删除任务
  Future<void> remove(String id) async {
    state.removeWhere((k, v) => v.id == id); // 删除
    ref.notifyListeners(); // 更新监听
  }
}
