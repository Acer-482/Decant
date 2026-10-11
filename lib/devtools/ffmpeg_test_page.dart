import 'dart:convert';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_transcoder/domain/encoder/video_encoder.dart';
import 'package:media_transcoder/domain/encoder/encoder_platform.dart';
import 'package:media_transcoder/domain/encoder/encoder_type.dart';
import 'package:media_transcoder/domain/encoder/available_encoder.dart';

/// 测试页面
class FFmpegTestPage extends StatefulWidget {
  const FFmpegTestPage({super.key});

  @override
  State<StatefulWidget> createState() => FFmpegTestPageState();
}

class FFmpegTestPageState extends State<FFmpegTestPage> {
  final List<String> log = []; // 输出日志
  PlatformFile? pickedFile; // 选择文件
  VideoEncoder? videoEncoder; // 编码器类型

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
                  onPressed: _getAvalibleDecoder,
                  child: Text('获取可用编解码器'),
                ),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text(
                    '选择文件${pickedFile == null ? '' : ' (${pickedFile?.path})'}',
                  ),
                ),
                ElevatedButton(onPressed: _getInfo, child: Text('获取文件信息')),
                Row(
                  mainAxisSize: .min,
                  children: [
                    Text('媒体编码器：'),
                    DropdownButton<VideoEncoder>(
                      value: videoEncoder,
                      borderRadius: .all(.circular(10)),
                      items: _buildDropdownItem(),
                      onChanged: (value) =>
                          setState(() => videoEncoder = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 获取可用编解码器
  void _getAvalibleDecoder() async {
    final data = await FFmpegKit.execute('-encoders');
    final output = await data.getOutput() ?? '';
    debugPrint('原始输出：$output');
    _showInfoDialog(output);

    final encoderData = parseEncoders(output);
    debugPrint(
      'Json数据: ${encoderData.map((e) => '(name: ${e.name}, desc: ${e.description}, type: ${e.type})').join(', ')}',
    );
  }

  // 构建下拉菜单内容
  List<DropdownMenuItem<VideoEncoder>> _buildDropdownItem() =>
      VideoEncoder.values.map((e) {
        String text = '[${e.codec.displayName}] ${e.type.displayName}'; // 编码器类型
        // 硬件编码器 //
        if (e.type == .hardware) {
          text += ' (${e.platforms.map((e) => e.displayName).join('、')})';
        }
        return DropdownMenuItem(value: e, child: Text(text)); // 构建下拉菜单
      }).toList();

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
    final infoJson = JsonEncoder.withIndent('\t')
        .convert(mediaInfo.getAllProperties());
    debugPrint('媒体信息: \n$infoJson');
    _showInfoDialog(infoJson);
    setState(() {}); // 更新状态
  }

  Future<void> _showInfoDialog(String text) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Text(text, textAlign: TextAlign.start),
        ),
      ),
    );
  }
}
