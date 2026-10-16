import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/domain/media/media_source/local_media_file_source.dart';
import 'package:media_transcoder/domain/task/media_transcode_task.dart';
import 'package:media_transcoder/domain/task/task_state.dart';
import 'package:media_transcoder/features/task_list/pages/form/base_task_form_page.dart';
import 'package:media_transcoder/shared/widgets/option_group.dart';

/// 媒体任务表单页面
class MediaTranscodeTaskFormPage extends BaseTaskFormPage<MediaTranscodeTask> {
  const MediaTranscodeTaskFormPage({super.initialTask, super.key});

  @override
  ConsumerState<BaseTaskFormPage<MediaTranscodeTask>> createState() =>
      MediaTaskFormPageState();
}

class MediaTaskFormPageState extends BaseTaskFormPageState<MediaTranscodeTask> {
  /// 媒体文件路径
  String? _mediaPath;

  /// 获取媒体文件
  Future<void> _pickMedia() async {
    final pickedFile = await FilePicker.pickFile(
      dialogTitle: '选择媒体文件',
      type: .media,
      windowsOptions: WindowsOptions(lockParentWindow: true), // 模态窗口
    );
    if (pickedFile == null) return;
    _mediaPath = pickedFile.path;
    setState(() {});
  }

  @override
  void initFormWidgets(MediaTranscodeTask? initialTask) {
    /// 为本地媒体文件资源
    if (initialTask?.source is LocalMediaFileSource) {
      final localMediaFileSource = initialTask!.source as LocalMediaFileSource;
      _mediaPath = localMediaFileSource.path;
    }
  }

  @override
  List<Widget> buildFormWidgets(BuildContext context) {
    return [
      OptionGroup(
        title: '媒体转码',
        children: [
          ListTile(
            title: Text('媒体源'),
            subtitle: _mediaPath == null ? null : Text(_mediaPath!),
            trailing: TextButton.icon(
              onPressed: _pickMedia,
              label: Text('选择文件'),
            ),
          ),
          // if (_mediaPath != null) MediaInfoCard(path: _mediaPath!),
        ],
      ),
    ];
  }

  @override
  MediaTranscodeTask buildTask({
    required String id,
    required String name,
    required String notes,
    required TaskState state,
    required DateTime createdStamp,
  }) {
    return MediaTranscodeTask(
      id: id,
      name: name,
      notes: notes,
      state: state,
      createdStamp: createdStamp,
      source: LocalMediaFileSource(path: _mediaPath ?? ''),
      streamConfigs: [],
      outputPath: 'output.mp4',
    );
  }
}
