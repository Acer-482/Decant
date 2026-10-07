import 'dart:convert';

import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// 测试页面
class FFmpegTestPage extends StatefulWidget {
  const FFmpegTestPage({super.key});

  @override
  State<StatefulWidget> createState() => FFmpegTestPageState();
}

class FFmpegTestPageState extends State<FFmpegTestPage> {
  final List<String> log = []; // 输出日志
  PlatformFile? pickedFile; // 选择文件

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: Container(
            padding: .all(10),
            child: Column(
              mainAxisSize: .min,
              spacing: 20,
              children: [
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text(
                    '选择文件${pickedFile == null ? '' : ' (${pickedFile?.path})'}',
                  ),
                ),
                ElevatedButton(onPressed: _getInfo, child: Text('获取文件信息')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 选择文件
  void _pickFile() async {
    final file = await FilePicker.pickFile(dialogTitle: '选择文件');
    if (file == null) return;
    pickedFile = file; // 选择文件
    setState(() {}); // 更新状态
  }

  // 获取文件信息
  void _getInfo() async {
    if (pickedFile?.path == null) return;
    // 获取信息 //
    final path = pickedFile!.path; // 获取路径
    debugPrint('路径：$path');

    // 改用 getMediaInformation
    final session = await FFprobeKit.getMediaInformation(path!);
    final mediaInfo = session.getMediaInformation();

    if (mediaInfo == null) {
      // 错误输出日志
      debugPrint('转码失败: ${await session.getAllLogsAsString()}');
      return;
    }
    // 显示信息 //
    mediaInfo.getStreams()[0].getCodec();
    final infoJson = JsonEncoder.withIndent('\t')
        .convert(mediaInfo.getAllProperties());
    debugPrint('媒体信息: \n$infoJson');
    final context = this.context;
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Text(infoJson, textAlign: TextAlign.start),
          ),
        ),
      );
    }
    setState(() {}); // 更新状态
  }
}
