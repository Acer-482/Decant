import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/domain/task/base_task.dart';
import 'package:media_transcoder/features/task_list/providers/task_list_notifier.dart';
import 'package:media_transcoder/features/task_list/utils/task_state_ui.dart';

/// 任务列表页面
class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskList = ref.watch(sortedTaskListProvider); // 任务列表
    final notifier = ref.read(taskListProvider.notifier); // 任务列表提供器
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTask(notifier),
        icon: Icon(Icons.add),
        label: Text('新建任务'),
      ),
      body: Container(
        padding: .all(10), // 内边距
        child: Column(
          crossAxisAlignment: .center, // 交叉方向中心对齐
          children: [Expanded(child: _buildTaskList(taskList))],
        ),
      ),
    );
  }

  /// 构建任务列表
  Widget _buildTaskList(List<BaseTask> taskList) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        final task = taskList[index];
        return Card(
          child: ListTile(
            title: Text(task.name),
            subtitle: Text(task.notes),
            trailing: task.state.displayText,
            onTap: () {},
          ),
        ); // 列表卡片
      },
    );
  }

  /// 添加任务
  void _addTask(TaskListNotifier taskListNotifier) {
    // taskListNotifier.add();
  }
}
