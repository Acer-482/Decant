import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:media_transcoder/domain/task/base_task.dart';
import 'package:media_transcoder/domain/task/task_state.dart';
import 'package:media_transcoder/features/task_list/providers/task_list_notifier.dart';
import 'package:media_transcoder/features/task_list/utils/task_state_ui.dart';
import 'package:media_transcoder/shared/widgets/option_group.dart';
import 'package:uuid/uuid.dart';

/// 任务表单页面
///
/// 使用模板方法模式允许子类通过钩子向父类传递组件，统一风格
abstract class BaseTaskFormPage<T extends BaseTask>
    extends ConsumerStatefulWidget {
  /// 初始任务
  ///
  /// 为null时创建，否则修改
  final T? initialTask;

  const BaseTaskFormPage({super.key, this.initialTask});

  @override
  ConsumerState<BaseTaskFormPage<T>> createState();
}

abstract class BaseTaskFormPageState<T extends BaseTask>
    extends ConsumerState<BaseTaskFormPage<T>> {
  /// 任务名称 表单控制器
  late final TextEditingController taskNameController;

  /// 任务备注 表单控制器
  late final TextEditingController taskNotesController;

  /// 任务状态
  late TaskState taskState;

  /// 表单
  final GlobalKey<FormState> _formKeys = GlobalKey();

  /// 表单标题
  String get formTitle =>
      widget.initialTask == null ? '创建任务' : '修改 ${widget.initialTask!.name} 任务';

  /// 初始化表单控件
  void initFormWidgets(T? initialTask);

  /// 构建表单控件
  List<Widget> buildFormWidgets(BuildContext context);

  /// 构建任务
  T buildTask({
    required String id,
    required String name,
    required String notes,
    required TaskState state,
    required DateTime createdStamp,
  });

  @override
  void initState() {
    super.initState();
    final initialTask = widget.initialTask;

    taskNameController = TextEditingController(text: initialTask?.name);
    taskNotesController = TextEditingController(text: initialTask?.notes);
    taskState = initialTask?.state ?? .pending;

    initFormWidgets(initialTask);
  }

  @override
  Widget build(BuildContext context) {
    final formWidgets = [
      _buildBaseTaskForm(),
      ...buildFormWidgets(context),
      if (widget.initialTask != null) _buildOtherInfo(widget.initialTask!),
    ]; // 表单控件
    return Scaffold(
      appBar: AppBar(title: Text(formTitle)),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: .all(12),
          child: Form(
            key: _formKeys,
            child: ListView.separated(
              itemCount: formWidgets.length,
              itemBuilder: (context, index) => formWidgets[index],
              separatorBuilder: (context, index) => const Divider(), // 分割线
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submit,
        child: Icon(Icons.check),
      ), // 提交按钮
    );
  }

  /// 构建基本任务表单
  Widget _buildBaseTaskForm() {
    return OptionGroup(
      title: '基本',
      children: [
        TextFormField(
          controller: taskNameController,
          decoration: InputDecoration(
            icon: Icon(Icons.abc),
            label: Text('名称'),
            hint: Text('将会显示在任务列表标题'),
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              (value == null || value.isEmpty) ? '任务名称不能为空' : null,
        ), // 名称
        TextFormField(
          controller: taskNotesController,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(
            icon: Icon(Icons.note_alt),
            label: Text('备注'),
            border: OutlineInputBorder(),
          ),
        ), // 备注
        DropdownButtonFormField<TaskState>(
          initialValue: taskState,
          decoration: InputDecoration(
            icon: Icon(Icons.flag),
            label: Text('状态'),
            border: OutlineInputBorder(),
          ),
          items: TaskState.values
              .map(
                (state) =>
                    DropdownMenuItem(value: state, child: state.displayText),
              )
              .toList(),
          onChanged: (value) => setState(() => taskState = value ?? .pending),
        ), // 状态
      ],
    );
  }

  Widget _buildOtherInfo(BaseTask initialTask) {
    return OptionGroup(
      title: '其他信息',
      children: [
        ListTile(
          leading: Icon(Icons.timelapse),
          title: Text('ID'),
          trailing: SelectableText(initialTask.id),
        ),
        ListTile(
          leading: Icon(Icons.timelapse),
          title: Text('创建时间'),
          trailing: SelectableText(
            DateFormat.yMMMd().format(initialTask.createdStamp),
          ),
        ),
        if (initialTask.finishedStamp != null)
          ListTile(
            leading: Icon(Icons.timelapse),
            title: Text('完成时间'),
            trailing: SelectableText(
              DateFormat.yMMMd().format(initialTask.finishedStamp!),
            ),
          ),
      ],
    );
  }

  /// 提交
  void _submit() {
    if (_formKeys.currentState?.validate() == true) {
      final createMode = widget.initialTask == null;
      // 创建任务
      final newTask = buildTask(
        id: createMode ? Uuid().v4() : widget.initialTask!.id,
        name: taskNameController.text,
        notes: taskNotesController.text,
        state: taskState,
        createdStamp: createMode
            ? DateTime.now()
            : widget.initialTask!.createdStamp,
      );
      // 添加到任务列表
      final taskListNotifier = ref.read(taskListProvider.notifier);
      if (createMode) {
        taskListNotifier.add(newTask);
      } else {
        taskListNotifier.update(newTask);
      }
      // 返回上一页
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskNotesController.dispose();
    super.dispose();
  }
}
