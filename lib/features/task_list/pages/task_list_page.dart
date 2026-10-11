import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/domain/task/task_state.dart';
import 'package:media_transcoder/features/task_list/providers/task_list_notifier.dart';

/// 任务列表页面
class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(taskListProvider.notifier);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTask(notifier),
        icon: Icon(Icons.add),
        label: Text('新建任务'),
      ),
      body: Column(
        crossAxisAlignment: .center,
        children: [..._buildTaskList(ref)],
      ),
    );
  }

  /// 构建列表
  List<Widget> _buildTaskList(WidgetRef ref) {
    return ref
        .watch(sortedTaskListProvider)
        .map(
          (task) => ListTile(
            title: Text(task.name),
            subtitle: Row(
              mainAxisAlignment: .spaceAround,
              children: [Text(task.notes), Text(task.state.displayName)],
            ),
          ),
        )
        .toList();
  }

  /// 添加任务
  void _addTask(TaskListNotifier taskListNotifier) {
    // taskListNotifier.add();
  }
}
