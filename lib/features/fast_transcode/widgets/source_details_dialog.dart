import 'package:flutter/material.dart';
import 'package:decant/domain/media/media_info.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/widgets/file_info_card.dart';
import 'package:decant/features/fast_transcode/widgets/media_info_card.dart';
import 'package:decant/shared/utils/file_utils.dart';

/// 查看源文件与媒体信息
Future<void> showSourceDetailsDialog(
  BuildContext context, {
  required BaseSource source,
  MediaInfo? info,
  String? error,
}) {
  final name = source is FileSource
      ? FileUtils.fileName(source.path)
      : source.input;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(name),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            spacing: 8,
            children: [
              if (source is FileSource) FileInfoCard(path: source.path),
              if (info != null)
                MediaInfoCard(info: info)
              else if (error != null)
                Text('媒体信息解析失败\n$error', textAlign: .center)
              else
                const Text('正在解析媒体信息…', textAlign: .center),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
}
