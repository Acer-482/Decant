import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/domain/task/base_task.dart';
import 'package:media_transcoder/domain/task/task_state.dart';
import 'package:media_transcoder/features/task_list/providers/task_list_notifier.dart';
import 'package:media_transcoder/features/task_list/utils/task_state_ui.dart';
import 'package:media_transcoder/shared/widgets/form_group.dart';
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
    ]; // 表单控件
    return Scaffold(
      appBar: AppBar(title: Text(formTitle)),
      body: Form(
        key: _formKeys,
        child: ListView.separated(
          itemCount: formWidgets.length,
          itemBuilder: (context, index) => formWidgets[index],
          separatorBuilder: (context, index) => const Divider(), // 分割线
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
    return FormGroup(
      title: '基本',
      formItems: [
        TextFormField(
          controller: taskNameController,
          decoration: InputDecoration(
            icon: Icon(Icons.abc),
            label: Text('名称'),
            hint: Text('该任务名称，将会显示在任务列表标题'),
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
        ListTile(
          title: Text('状态'),
          subtitle: Text('该任务的初始状态'),
          trailing: DropdownButton(
            items: TaskState.values
                .map(
                  (state) =>
                      DropdownMenuItem(value: state, child: state.displayText),
                )
                .toList(),
            value: taskState,
            onChanged: (value) => setState(() => taskState = value ?? .pending),
          ),
        ), // 状态
      ],
    );
  }

  /// 提交
  void _submit() {
    if (_formKeys.currentState?.validate() == true) {
      // 创建任务
      final newTask = buildTask(
        id: Uuid().v4(),
        name: taskNameController.text,
        notes: taskNotesController.text,
        state: taskState,
        createdStamp: DateTime.now(),
      );
      // 添加到任务列表
      ref.read(taskListProvider.notifier).add(newTask);
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
